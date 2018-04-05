-- CA Technologies
-- Database schema for OTK
--
-- This script is used to create OAuth default test clients for testing purposes in non-production environments.
--
-- This script inserts test data. It is not necessary but recommended to install this script in non-production environments.
-- It is provided for testing purposes only.
--
-- NOTE: this script will first remove all existing test data!
--
-- run this command on command line to create the Cassandra schema: cqlsh -k <keyspace> -f <this-file-name>.cql
--
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
VALUES ('54f0c455-4d80-421f-82ca-9194df24859d', 'a0f2742f-31c7-436f-9802-b7015b8fd8e6', 'ENABLED', 'admin', 'TestClient2.0', 'YOUR_SSG/oauth/v2/client/authcode?auth=done,YOUR_SSG/oauth/v2/client/implicit?auth=done', 0, 0, 'ALL', 'oob', '{}', 0);

INSERT INTO oauth_client_key_user (client_key, created_by, client_ident)
VALUES ('acf89db2-994e-427b-ac2c-88e6101f9433', 'admin', 'TestClient1.0');

INSERT INTO oauth_client_key_user (client_key, created_by, client_ident)
VALUES ('54f0c455-4d80-421f-82ca-9194df24859d', 'admin', 'TestClient2.0');
