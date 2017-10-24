--
-- PostgreSQL version of Quick Start Template Registrar database creation script.
--

DROP TABLE IF EXISTS template_registrar;

CREATE TABLE template_registrar (
  name varchar(255) NOT NULL,   -- same as published_service name field
  uri varchar(255) NOT NULL,  -- max size is 255 for unique index
  time varchar(32) NOT NULL,
  template TEXT NOT NULL,
  PRIMARY KEY (name)
);

ALTER TABLE template_registrar ADD CONSTRAINT uri_ID UNIQUE (uri);

