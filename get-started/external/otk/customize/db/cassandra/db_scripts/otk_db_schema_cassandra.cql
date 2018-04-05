-- CA Technologies
-- Database schema for OTK
--
-- run this command on command line to create the Cassandra schema: cqlsh -k <keyspace> -f <this-file-name>.cql
--
-- This table holds valid client application values as defined when the application was registered
--
CREATE TABLE oauth_client (
	client_ident text PRIMARY KEY,
	name text,
	type text,
	description text,
	organization text,
	registered_by text,
	created bigint,
	custom text
);
--
-- used to look up a client by name or name and organization
--
CREATE TABLE oauth_client_name (
	name text,
	client_ident text,
	organization text,
	PRIMARY KEY (name, organization, client_ident)
);
--
-- used to look up a client by organization
--
CREATE TABLE oauth_client_org (
	organization text,
	client_ident text,
	PRIMARY KEY (organization, client_ident)
);
--
-- This table holds valid client keys. It also includes data of the parent oauth_client
--
CREATE TABLE oauth_client_key (
	client_key text,
	secret text,
	scope text,
	callback text,
	environment text,
	expiration bigint,
	status text,
	created bigint,
	created_by text,
	client_ident text,
	custom text,
	serviceIds text,
	accountPlanMappingIds text,
	master int,
	PRIMARY KEY(client_key, client_ident)
);
--
-- used to find client keys by users
--
CREATE TABLE oauth_client_key_user (
	created_by text,
	client_ident text,
	client_key text,
	PRIMARY KEY( (created_by, client_key) , client_ident)
);
--
-- Create required indexes
--
CREATE INDEX ON oauth_client (registered_by);
CREATE INDEX ON oauth_client_key (client_ident);
CREATE INDEX ON oauth_client_key_user (client_ident);

--
-- Allow queries for types of Client Keys (Master|Non-Master) belonging to a specific App
--
CREATE MATERIALIZED VIEW app_instances
AS SELECT client_key, client_ident, master
FROM oauth_client_key WHERE client_key IS NOT NULL AND client_ident IS NOT NULL AND master IS NOT NULL PRIMARY KEY (client_ident, master, client_key);

--
-- This table holds access_tokens
--
CREATE TABLE oauth_access_token (
	otk_token text PRIMARY KEY,
	secret text,
	expiration bigint,
	scope text,
	resource_owner text,
	created bigint,
	otoken text, // other token = refresh token
	oexpiration bigint,
	status text,
	client_key text,
	client_name text,
	client_ident text,
	custom text
);

CREATE INDEX ON oauth_access_token (client_ident);

CREATE TABLE oauth_access_token_view_client_key (
    otk_token text,
    resource_owner text,
    client_key text,
	client_name text,
	PRIMARY KEY (client_key, resource_owner, otk_token)
);

CREATE TABLE oauth_access_token_view_resource_owner (
    otk_token text,
    resource_owner text,
    client_key text,
	status text,
    client_name text,
	PRIMARY KEY (resource_owner, client_key, otk_token)
);

CREATE TABLE oauth_access_token_view_client_ident (
    otk_token text,
    client_ident text,
    resource_owner text,
    created bigint,
    PRIMARY KEY((client_ident, resource_owner), created, otk_token)
);

--
-- Allow queries for all Tokens belonging to an App
--
CREATE MATERIALIZED VIEW app_active_users
AS SELECT client_ident, otk_token FROM oauth_access_token
WHERE client_ident IS NOT NULL AND otk_token IS NOT NULL PRIMARY KEY (client_ident, otk_token);

CREATE INDEX ON oauth_access_token_view_resource_owner (status);

--
-- This table uses for pagination
--
CREATE TABLE oauth_access_token_pagination (
	otk_token text,
	client_name_otk_token text,
	secret text,
	expiration bigint,
	scope text,
	resource_owner text,
	created bigint,
	otoken text, // other token = refresh token
	oexpiration bigint,
	status text,
	client_key text,
	client_name text,
	custom text,
	PRIMARY KEY (client_name_otk_token, resource_owner, otk_token)
);

CREATE INDEX ON oauth_access_token_pagination (status);
CREATE INDEX ON oauth_access_token_pagination (client_key);

--
-- This table holds refresh_tokens
--
CREATE TABLE oauth_refresh_token (
	otk_token text PRIMARY KEY,
	secret text,
	expiration bigint,
	scope text,
	resource_owner text,
	created bigint,
	otoken text, // other token = access token
	oexpiration bigint,
	status text,
	client_key text,
	client_name text,
	custom text
);

CREATE TABLE oauth_refresh_token_view_client_key (
	otk_token text,
	resource_owner text,
	client_key text,
        client_name text,
	PRIMARY KEY (client_key, resource_owner, otk_token)
);

CREATE TABLE oauth_refresh_token_view_resource_owner (
	otk_token text,
	resource_owner text,
	client_key text,
	status text,
    client_name text,
	PRIMARY KEY (resource_owner, client_key, otk_token)
);

--
-- This table holds temporary tokens
-- oauth 1.0 = request_token
-- oauth 2.0 = authorization_code
--
CREATE TABLE oauth_initiate (
    otk_token text PRIMARY KEY,
    secret text,
    expiration bigint,
    scope text,
    resource_owner text,
    created bigint,
    verifier text,
    callback text,
    client_key text,
    client_name text,
	custom text
);

CREATE TABLE oauth_initiate_view_verifier (
    otk_token text,
    verifier text,
    PRIMARY KEY (otk_token, verifier)
);

CREATE TABLE oauth_initiate_view_client_key (
    otk_token text,
    client_key text,
	client_name text,
	resource_owner text,
	PRIMARY KEY (client_key, otk_token)
);

CREATE TABLE oauth_initiate_view_resource_owner (
    otk_token text,
    resource_owner text,
    client_key text,
 PRIMARY KEY (resource_owner, client_key, otk_token)
);

--
-- This table holds session info
--
CREATE TABLE oauth_session (
  session_key text,
  session_group text,
  expiration bigint,
  value text,
  PRIMARY KEY(session_key, session_group)
);
--
CREATE TABLE otk_version (
  current_version text PRIMARY KEY
);
INSERT INTO otk_version (current_version) VALUES ('otk4.1.00');
--
-- This table will contain all id_token
--
CREATE TABLE oauth_id_token (
  resource_owner text,
  azp text,
  sub text,
  jwt_id text,
  jwt text,
  salt text,
  shared_secret text,
  shared_secret_type text,
  iss text,
  expiration bigint ,
  PRIMARY KEY(resource_owner, azp)
);
--
-- The following tables are the "views" for id_token
--
CREATE TABLE oauth_id_token_view_sub (
  resource_owner text,
  azp text,
  sub text,
  jwt_id text,
  jwt text,
  salt text,
  shared_secret text,
  shared_secret_type text,
  iss text,
  expiration bigint ,
  PRIMARY KEY(sub, azp)
);
CREATE TABLE oauth_id_token_view_azp (
  resource_owner text,
  azp text,
  sub text,
  jwt_id text,
  jwt text,
  salt text,
  shared_secret text,
  shared_secret_type text,
  iss text,
  expiration bigint ,
  PRIMARY KEY(azp)
);
CREATE TABLE oauth_id_token_view_jwt_id (
  resource_owner text,
  azp text,
  sub text,
  jwt_id text,
  jwt text,
  salt text,
  shared_secret text,
  shared_secret_type text,
  iss text,
  expiration bigint ,
  PRIMARY KEY(jwt_id)
);
CREATE TABLE oauth_id_token_view_jwt (
  resource_owner text,
  azp text,
  sub text,
  jwt_id text,
  jwt text,
  salt text,
  shared_secret text,
  shared_secret_type text,
  iss text,
  expiration bigint,
  PRIMARY KEY(jwt)
);
--
-- truncate all the data
--
truncate oauth_client;
truncate oauth_client_name;
truncate oauth_client_org;
truncate oauth_client_key;
truncate oauth_client_key_user;
--
-- OpenID Connect Client for the Basic Client Profile specification
--
INSERT INTO oauth_client (client_ident, name, description, organization, registered_by, type, created, custom)
VALUES ('123456800-otk', 'OpenID Connect Basic Client Profile', 'Test for OpenID Connect BCP', 'CA Technologies Inc.', 'admin', 'confidential', 0, '{}');
--
INSERT INTO oauth_client_name (client_ident, name, organization)
VALUES ('123456800-otk', 'OpenID Connect Basic Client Profile', 'CA Technologies Inc.');
--
INSERT INTO oauth_client_org (client_ident, organization)
VALUES ('123456800-otk', 'CA Technologies Inc.');

INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, callback, scope, expiration, created, environment, custom, master)
VALUES ('5eed868e-7ad0-4172-88f2-704bcf78b61e', '2054e4d7-77f2-46c9-bc4d-11a47255a6ec', 'ENABLED', 'admin', '123456800-otk', 'YOUR_SSG/oauth/v2/client/bcp?auth=done', 'openid email profile phone address', 0, 0, 'ALL', '{}', 0);

INSERT INTO oauth_client_key_user (client_key, created_by, client_ident)
VALUES ('5eed868e-7ad0-4172-88f2-704bcf78b61e','admin', '123456800-otk');

--
-- OpenID Connect Client for the Implicit Client Profile specification
--
INSERT INTO oauth_client (client_ident, name, description, organization, registered_by, type, created, custom)
VALUES ('123456801-otk', 'OpenID Connect Implicit Client Profile', 'Test for OpenID Connect ICP', 'CA Technologies Inc.', 'admin', 'public', 0, '{}');
--
INSERT INTO oauth_client_name (client_ident, name, organization)
VALUES ('123456801-otk', 'OpenID Connect Implicit Client Profile', 'CA Technologies Inc.');
--
INSERT INTO oauth_client_org (client_ident, organization)
VALUES ('123456801-otk', 'CA Technologies Inc.');

INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, callback, scope, expiration, created, environment, custom, master)
VALUES ('5edc4a38-75ec-4617-8854-1a71ff1e0a2e', '5005a669-0295-4602-be7d-6a75342db6d8', 'ENABLED', 'admin', '123456801-otk', 'YOUR_SSG/oauth/v2/client/icp?auth=done', 'openid email profile phone address', 0, 0, 'ALL', '{}', 0);

INSERT INTO oauth_client_key_user (client_key, created_by, client_ident)
VALUES ('5edc4a38-75ec-4617-8854-1a71ff1e0a2e', 'admin', '123456801-otk');

--
-- Create an OAuth 1.0 and OAuth 2.0 client
--
INSERT INTO oauth_client (client_ident, name, description, organization, registered_by, created, type, custom)
VALUES ('TestClient1.0', 'OAuth1Client', 'OAuth 1.0 test client hosted on the ssg', 'CA Technologies Inc.', 'admin', 0, 'oob', '{}');
--
INSERT INTO oauth_client_name (client_ident, name, organization)
VALUES ('TestClient1.0', 'OAuth1Client', 'CA Technologies Inc.');
--
INSERT INTO oauth_client_org (client_ident, organization)
VALUES ('TestClient1.0', 'CA Technologies Inc.');
--
INSERT INTO oauth_client (client_ident, name, description, organization, registered_by, type, created, custom)
VALUES ('TestClient2.0', 'OAuth2Client', 'OAuth 2.0 test client hosted on the ssg', 'CA Technologies Inc.', 'admin', 'confidential', 0, '{}');
--
INSERT INTO oauth_client_name (client_ident, name, organization)
VALUES ('TestClient2.0', 'OAuth2Client', 'CA Technologies Inc.');
--
INSERT INTO oauth_client_org (client_ident, organization)
VALUES ('TestClient2.0', 'CA Technologies Inc.');
--
INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, scope, expiration, created, environment, callback, custom, master)
VALUES ('acf89db2-994e-427b-ac2c-88e6101f9433', '74d5e0db-cd8b-4d8e-a989-95a0746c3343', 'ENABLED', 'admin', 'TestClient1.0', 'scope_test', 0, 0, 'ALL', 'oob', '{}', 0);

INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, callback, expiration, created, environment, scope, custom, master)
VALUES ('54f0c455-4d80-421f-82ca-9194df24859d', 'a0f2742f-31c7-436f-9802-b7015b8fd8e6', 'ENABLED', 'admin', 'TestClient2.0', 'YOUR_SSG/oauth/v2/client/authcode,YOUR_SSG/oauth/v2/client/implicit', 0, 0, 'ALL', 'oob', '{}', 0);

INSERT INTO oauth_client_key_user (client_key, created_by, client_ident)
VALUES ('acf89db2-994e-427b-ac2c-88e6101f9433', 'admin', 'TestClient1.0');

INSERT INTO oauth_client_key_user (client_key, created_by, client_ident)
VALUES ('54f0c455-4d80-421f-82ca-9194df24859d', 'admin', 'TestClient2.0');
