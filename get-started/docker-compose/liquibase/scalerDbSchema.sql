--
-- MariaDB version of Quick Start Template Registrar database creation script.
--

DROP TABLE IF EXISTS template_registrar;

CREATE TABLE template_registrar (
  name varchar(255) NOT NULL,   -- same as published_service name field
  uri varchar(255) not null,  -- max size is 255 for unique index
  time bigint(20) NOT NULL,
  template varchar(4096) NOT NULL,
  PRIMARY KEY (name)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

ALTER TABLE template_registrar ADD UNIQUE INDEX uri_ID (uri);

