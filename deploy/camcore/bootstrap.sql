-- CamCore safety bootstrap for Listmonk.
-- Runs after Listmonk's idempotent installer and before the application starts.

-- Listmonk v6.2.0 seeds an enabled sample SMTP server. Disable only the seeded
-- example entries. A future real CamCore SMTP configuration is left untouched
-- on later Portainer redeployments.
UPDATE settings
SET value = COALESCE((
  SELECT jsonb_agg(
    CASE
      WHEN (entry->>'host' = 'smtp.yoursite.com' AND entry->>'username' = 'username')
        OR (entry->>'host' = 'smtp.gmail.com' AND entry->>'username' = 'username@gmail.com')
      THEN jsonb_set(entry, '{enabled}', 'false'::jsonb, true)
      ELSE entry
    END
  )
  FROM jsonb_array_elements(value) AS entry
), '[]'::jsonb),
    updated_at = NOW()
WHERE key = 'smtp';

-- Apply the initial CamCore identity only while the installation still has
-- Listmonk's untouched default root URL. This makes the bootstrap idempotent
-- without overwriting later administrator choices on every redeploy.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM settings
    WHERE key = 'app.root_url'
      AND value = '"http://localhost:9000"'::jsonb
  ) THEN
    UPDATE settings SET value = '"CamCore News & Updates"'::jsonb, updated_at = NOW()
    WHERE key = 'app.site_name';

    UPDATE settings SET value = '"https://camcore.au/news"'::jsonb, updated_at = NOW()
    WHERE key = 'app.root_url';

    UPDATE settings SET value = '"CamCore <help@camcore.au>"'::jsonb, updated_at = NOW()
    WHERE key = 'app.from_email';

    UPDATE settings SET value = 'true'::jsonb, updated_at = NOW()
    WHERE key = 'app.enable_public_archive';

    UPDATE settings SET value = 'false'::jsonb, updated_at = NOW()
    WHERE key = 'app.enable_public_subscription_page';

    UPDATE settings SET value = 'false'::jsonb, updated_at = NOW()
    WHERE key = 'app.send_optin_confirmation';

    UPDATE settings SET value = '[]'::jsonb, updated_at = NOW()
    WHERE key = 'app.notify_emails';
  END IF;
END $$;
