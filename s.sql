CREATE TABLE incoming
(
    id    serial primary key,
    target_coords VARCHAR,
    attacker_coords VARCHAR,
    eta VARCHAR,
    org_eta VARCHAR,
    fleet_name VARCHAR,
    fleet_count VARCHAR,
    incoming_class VARCHAR,
    fleet_type VARCHAR,
    war boolean,
    target_x integer,
    target_y integer,
    target_z integer,
    attacker_x integer,
    attacker_y integer,
    attacker_z integer,
    tick integer
);
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

alter table incoming add column ally varchar;
ALTER TABLE incoming ADD fleet_id uuid DEFAULT uuid_generate_v4();
alter table incoming add column created_at timestamp default now();
alter table incoming add column updated_at timestamp default now();

alter table heresy_users add column chat_id  varchar;
alter table heresy_users add column nick  varchar;

alter table heresy_users add column ally  varchar;
alter table heresy_users add column name  varchar;

alter table updates add column defence_check  boolean default false;


CREATE TABLE user_feed
(
    id    serial primary key,
    tick integer,
    type_ VARCHAR,
    text VARCHAR
);
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE incs_peeps
(
    id    serial primary key,
    attacker_x integer,
    attacker_y integer,
    attacker_z integer,
    date date,
    ally varchar,
    incs integer
);

CREATE TABLE incs_data
(
    id    serial primary key,
    date date,
    ally varchar,
    incs integer
);