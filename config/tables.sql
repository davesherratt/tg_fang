create table heresy_notification (	"id" uuid DEFAULT uuid_generate_v4() NOT NULL,	"user_id" int4,	"message" varchar);