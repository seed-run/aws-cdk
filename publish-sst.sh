#!/usr/bin/env node
const { execSync } = require('child_process');
const { readFileSync, writeFileSync } = require('fs');

const code = process.argv[2];

// Get forked AWS CDK version
const cdkVersion = JSON.parse(readFileSync('version.v1.json')).version;

// Use real versions
execSync(`scripts/align-version.sh`);

// Generate new version
const prevForkVersion = execSync(`npm show @seed-run/aws-cdk version`).toString().trim();
const prevCdkVersion = prevForkVersion.split('-')[0];
const prevRevision = prevForkVersion.split('.').pop();
const revision = prevCdkVersion === cdkVersion
  ? parseInt(prevRevision) + 1
  : 1;
const forkVersion = `${cdkVersion}-seed.${revision}`;

// Update package.json
const packageJson = JSON.parse(readFileSync("packages/aws-cdk/package.json"));
if (packageJson.name !== "aws-cdk"
  || packageJson.repository.url !== "https://github.com/aws/aws-cdk.git"
  || packageJson.homepage !== "https://github.com/aws/aws-cdk"
  || packageJson.version !== cdkVersion) {
  throw new Error("Package name mismatch");
}
packageJson.name = "@seed-run/aws-cdk";
packageJson.repository.url = "https://github.com/seed-run/aws-cdk.git";
packageJson.homepage = "https://github.com/seed-run/aws-cdk";
packageJson.version = forkVersion;
writeFileSync("packages/aws-cdk/package.json", JSON.stringify(packageJson, null, 2));

// Publish
execSync(`cd packages/aws-cdk && npm publish --access public --otp ${code}`);
execSync(`git reset --hard`);

// Tag
//execSync(`git tag v${forkVersion} && git push --tags`);
