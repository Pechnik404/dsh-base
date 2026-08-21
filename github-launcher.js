#!/usr/bin/env node
/**
 * GitHub MCP launcher (безопасный, для dsh-base).
 *
 * Читает GITHUB_TOKEN из хранилища секретов DSH
 * (~/.dsh/.credentials.yaml, права 0600) и запускает официальный
 * @modelcontextprotocol/server-github, передавая токен ТОЛЬКО через
 * окружение дочернего процесса. Токен никогда не логируется и не печатается.
 *
 * Официальный сервер читает переменную GITHUB_PERSONAL_ACCESS_TOKEN
 * (а не GITHUB_TOKEN) — передаются обе, для совместимости.
 */
'use strict';

const { spawn } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');

const DSH_HOME = process.env.DSH_HOME || path.join(os.homedir(), '.dsh');
const CREDENTIALS_FILE = path.join(DSH_HOME, '.credentials.yaml');

function extractToken() {
  let raw;
  try {
    raw = fs.readFileSync(CREDENTIALS_FILE, 'utf8');
  } catch (err) {
    process.stderr.write(`github-launcher: cannot read ${CREDENTIALS_FILE}: ${err.message}\n`);
    return undefined;
  }
  const line = raw.split(/\r?\n/).find((l) => /^GITHUB_TOKEN\s*:/.test(l));
  if (!line) {
    process.stderr.write('github-launcher: GITHUB_TOKEN not found in credentials store\n');
    return undefined;
  }
  let value = line.replace(/^GITHUB_TOKEN\s*:\s*/, '').trim();
  if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
    value = value.slice(1, -1);
  }
  if (value.length === 0) {
    process.stderr.write('github-launcher: GITHUB_TOKEN is empty\n');
    return undefined;
  }
  return value;
}

const token = extractToken();
if (token === undefined) {
  process.exit(1);
}

const child = spawn(
  'npx',
  ['-y', '@modelcontextprotocol/server-github'],
  {
    stdio: 'inherit',
    shell: process.platform === 'win32',
    env: {
      ...process.env,
      GITHUB_PERSONAL_ACCESS_TOKEN: token,
      GITHUB_TOKEN: token,
    },
  }
);

child.on('exit', (code) => {
  process.exit(code ?? 1);
});
child.on('error', (err) => {
  process.stderr.write(`github-launcher: failed to start server: ${err.message}\n`);
  process.exit(1);
});
