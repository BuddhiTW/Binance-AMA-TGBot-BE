// Runtime-friendly Knex configuration (CommonJS)
// Mirrors knexfile.ts but without TypeScript so CLI and dist runtime can load it.
/** @type {import('knex').Knex.PoolConfig} */
const defaultPoolConfig = {
  min: 2,
  max: 50,
  idleTimeoutMillis: 30000,
  acquireTimeoutMillis: 30000,
  createTimeoutMillis: 30000,
  reapIntervalMillis: 1000,
  createRetryIntervalMillis: 100,
};

const SRC_MIGRATIONS_DIR = "./src/migrations";
const SRC_SEEDS_DIR = "./src/fixtures";
const DIST_MIGRATIONS_DIR = "./dist/src/migrations";
const DIST_SEEDS_DIR = "./dist/src/fixtures";

const baseConnection = {
  host: process.env.PG_HOST,
  port: Number(process.env.PG_PORT),
  database: process.env.PG_DB,
  user: process.env.PG_USER,
  password: process.env.PG_PW,
  ssl: false,
  keepAlive: true,
  statement_timeout: 60000,
};

const config = {
  development: {
    client: 'pg',
    connection: baseConnection,
    pool: { ...defaultPoolConfig },
    migrations: {
      directory: process.env.KNEX_MIGRATIONS_DIR || SRC_MIGRATIONS_DIR,
      tableName: 'knex_migrations',
    },
    seeds: {
      directory: process.env.KNEX_SEEDS_DIR || SRC_SEEDS_DIR,
    },
  },
  production: {
    client: 'pg',
    connection: baseConnection,
    pool: { ...defaultPoolConfig },
    migrations: {
      directory: process.env.KNEX_MIGRATIONS_DIR || DIST_MIGRATIONS_DIR,
      tableName: 'knex_migrations',
    },
    seeds: {
      directory: process.env.KNEX_SEEDS_DIR || DIST_SEEDS_DIR,
    },
  },
  localhost: {
    client: 'pg',
    connection: {
      host: '127.0.0.1',
      port: 3009,
      database: 'binance-ama-bot',
      user: 'binance-ama-bot',
      password: 'binance-ama-bot',
      ssl: false,
      keepAlive: true,
      statement_timeout: 60000,
    },
    pool: { ...defaultPoolConfig, min: 2, max: 10 },
    migrations: { directory: SRC_MIGRATIONS_DIR, tableName: 'knex_migrations' },
    seeds: { directory: SRC_SEEDS_DIR },
  },
};

module.exports = config;
module.exports.default = config; // Support default import style
