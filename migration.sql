CREATE TYPE post_visibility_scope AS ENUM ('PUBLIC','CONTRACT','LOCATION','GROUP');
CREATE TABLE bookmarks (
post_id uuid REFERENCES posts(id) ON DELETE CASCADE,
user_id uuid NOT NULL,
created_at timestamptz DEFAULT now(),
PRIMARY KEY(post_id, user_id)
);


CREATE TABLE shares (
id uuid PRIMARY KEY,
post_id uuid REFERENCES posts(id) ON DELETE CASCADE,
user_id uuid NOT NULL,
share_channel text CHECK (share_channel IN ('INTERNAL','LINK')),
created_at timestamptz DEFAULT now()
);


CREATE TABLE comments (
id uuid PRIMARY KEY,
post_id uuid REFERENCES posts(id) ON DELETE CASCADE,
author_id uuid NOT NULL,
parent_id uuid NULL REFERENCES comments(id) ON DELETE CASCADE,
content text NOT NULL,
status text DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','DELETED','HIDDEN')),
created_at timestamptz DEFAULT now()
);
CREATE INDEX idx_comments_post_created ON comments(post_id, created_at);


CREATE TABLE post_counters (
post_id uuid PRIMARY KEY REFERENCES posts(id) ON DELETE CASCADE,
like_count bigint DEFAULT 0,
comment_count bigint DEFAULT 0,
share_count bigint DEFAULT 0,
bookmark_count bigint DEFAULT 0
);


CREATE TABLE groups (
id uuid PRIMARY KEY,
contract_id uuid NOT NULL,
name text,
description text,
is_private boolean DEFAULT false,
requires_post_approval boolean DEFAULT false,
location_scope uuid[] NULL,
created_by uuid NOT NULL,
created_at timestamptz DEFAULT now()
);
CREATE TABLE group_members (
group_id uuid REFERENCES groups(id) ON DELETE CASCADE,
user_id uuid NOT NULL,
role text CHECK (role IN ('member','admin')),
PRIMARY KEY(group_id, user_id)
);


CREATE TABLE admin_actions (
id uuid PRIMARY KEY,
actor_id uuid,
target_type text CHECK (target_type IN ('POST','COMMENT','USER')),
target_id uuid,
action text CHECK (action IN ('DELETE','DISABLE_COMMENTS','DISABLE_LIKES','RESTORE')),
reason text,
created_at timestamptz DEFAULT now()
);
CREATE TABLE reports (
id uuid PRIMARY KEY,
reporter_id uuid,
target_type text CHECK (target_type IN ('POST','COMMENT')),
target_id uuid,
reason text,
created_at timestamptz DEFAULT now()
);
