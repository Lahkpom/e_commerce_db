CREATE TABLE user_security_tokens (
    token_id    UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID            NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    token_hash  VARCHAR(255)    NOT NULL UNIQUE,
    token_type  VARCHAR(50)     NOT NULL, -- 'EMAIL_VERIFICATION', 'PASSWORD_RESET'
    expires_at  TIMESTAMPTZ     NOT NULL,
    consumed_at TIMESTAMPTZ     NULL,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sec_tokens_lookup ON user_security_tokens(token_hash) WHERE consumed_at IS NULL;