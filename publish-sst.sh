#!/usr/bin/env node
const { execSync } = require('child_process');
const { readFileSync } = require('fs');

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

// Publish
execSync(`cd packages/aws-cdk && sed -i '' "s/\\"name\\": \\"aws-cdk\\"/\\"name\\": \\"@seed-run\\/aws-cdk\\"/g" package.json`);
execSync(`cd packages/aws-cdk && sed -i '' "s/github.com\\/aws\\/aws-cdk/github.com\\/seed-run\\/aws-cdk/g" package.json`);
execSync(`cd packages/aws-cdk && sed -i '' "s/\\"version\\": \\"${cdkVersion}\\"/\\"version\\": \\"${forkVersion}\\"/g" package.json`);
execSync(`cd packages/aws-cdk && npm publish --access public --otp ${code}`);
execSync(`git reset --hard`);

// Tag
//execSync(`git tag v${forkVersion} && git push --tags`);

