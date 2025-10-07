const fs = require("fs");

const pullRequestNamePrefix = "Update Salesforce CLI to";

module.exports = ({ github, context, core, exec, fetch }) => {
    return {
        getLatestVersions: async () => {
            const cliVersion = await getLatestCliVersion(fetch);
            const { cliHash, yarnHash } = await getLatestHashes(
                exec,
                fetch,
                cliVersion,
            );

            return {
                cliVersion,
                cliHash,
                yarnHash,
            };
        },
        closeExistingPRs: async () => {
            const pullRequests = await github.rest.pulls.list({
                repo: context.repo.repo,
                owner: context.repo.owner,
                state: 'open',
            });

            const actionCreatedPRs = pullRequests.filter(pr => pr.title.startsWith(pullRequestNamePrefix));

            for (const pr of actionCreatedPRs) {
                await github.rest.pulls.update({
                    repo: context.repo.repo,
                    owner: context.repo.owner,
                    state: 'closed',
                });
            }
        },
        createNewPR: async (cliVersion, cliHash, yarnHash) => {
        },

    };
};

async function getLatestCliVersion(fetch) {
    const response = await fetch(
        "https://api.github.com/repos/salesforcecli/cli/releases/latest",
    );
    if (!response.ok) {
        throw new Error(
            `fetching the latest version of the salesforcecli repo failed with status code: ${response.status}`,
        );
    }

    return (await response.json()).tag_name;
}

async function getLatestHashes(exec, fetch, version) {
    const cliHash = await getRepoHash(exec, version);
    const yarnHash = await getYarnHash(exec, fetch, version);

    return { cliHash, yarnHash };
}

async function getRepoHash(exec, version) {
    const { exitCode, stdout, stderr } = await runExec(
        exec,
        "nix-prefetch-url",
        [
            "--print-path",
            "--unpack",
            `https://github.com/salesforcecli/cli/archive/refs/tags/${version}.tar.gz`,
        ],
    );

    if (exitCode !== 0) {
        throw new Error(
            `nix-prefetch-url returned with status code ${exitCode}: ${stderr}`,
        );
    }

    return stdout;
}

async function getYarnHash(exec, fetch, version) {
    const {
        exitCode,
        stdout: path,
        stderr,
    } = await runExec(exec, "mktemp", ["-d"]);

    if (exitCode !== 0) {
        throw new Error(
            `could not create new temporary directory, failed with ${exitCode}: ${stderr}`,
        );
    }

    const yarnLockFileRequest = await fetch(
        `https://raw.githubusercontent.com/salesforcecli/cli/${version}/yarn.lock`,
    );

    if (!yarnLockFileRequest.ok) {
        throw new Error(`could not fetch yarn lock file: ${yarnLockFileRequest.status}`);
    }

    const lockFileContents = await yarnLockFileRequest.text();

    const data = new Uint8Array(Buffer.from(lockFileContents));
    const lockFilePath = `${path}/yarn.lock`;

    fs.writeFile(lockFilePath, data);

    const { exitCode: prefetchExitCode, stdout: prefetchOut, stderr: prefetchErr } = await runExec(exec, "prefetch-yarn-deps", [lockFilePath]);

    if (prefetchExitCode !== 0) {
        throw new Error(`prefetch-yarn-deps failed with non-zero exit code ${prefetchExitCode}: ${prefetchErr}`);
    }

    const { exitCode: nixHashExitCode, stdout: yarnHash, stderr: nixHashError } = await runExec(exec, "nix", ["hash", "to-base64", "--type sha256", prefetchOut]);

    if (nixHashExitCode !== 0) {
        throw new Error(`nix hash exited with non-zero status code: ${nixHashExitCode}: ${nixHashError}`);
    }

    return yarnHash;
}

async function runExec(exec, cmd, args) {
    let stdout = "";
    let stderr = "";

    const options = {
        listeners: {
            stdout: (data) => {
                stdout += data.toString();
            },
            stderr: (data) => {
                stderr += data.toString();
            },
        },
    };

    const exitCode = exec.exec(cmd, args, options);

    return {
        exitCode,
        stdout,
        stderr,
    };
}
