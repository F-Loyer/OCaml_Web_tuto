create database test;
create table test.t1 (id integer auto_increment primary key, value text);;
grant all privileges on test.* to "login"@"localhost" identified by "password";
CREATE TABLE test.dream_session (
  id VARCHAR(255) PRIMARY KEY,
  label TEXT NOT NULL,
  expires_at REAL NOT NULL,
  payload TEXT NOT NULL
)
