CREATE TABLE accounts (
  id bigint PRIMARY KEY NOT NULL,
  name text,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
  id SERIAL PRIMARY KEY NOT NULL,
  account_id bigint NOT NULL REFERENCES accounts(id),
  title text,
  content text,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE blogs (
  id SERIAL PRIMARY KEY NOT NULL,
  account_id bigint NOT NULL REFERENCES accounts(id),
  title text,
  description text,
  coverimage VARCHAR(255),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX uk_account_id ON blogs(account_id);

CREATE TABLE sessions (
  id CHAR(36) PRIMARY KEY,
  account_id bigint NOT NULL REFERENCES accounts(id),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_accessed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
