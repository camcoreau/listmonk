-- CamCore safety bootstrap for Listmonk.
-- This runs after Listmonk's idempotent installer and before the application starts.

-- Fresh Listmonk installs seed an enabled sample SMTP server. Disable every
-- configured SMTP entry so a new deployment cannot send mail until an
-- administrator deliberately enables the Ganymede relay later.
UPDATE settings
SET value = COALESCE((
  SELECT jsonb_agg(jsonb_set(entry, '{enabled}', 'false'::jsonb, true))
  FROM jsonb_array_elements(value) AS entry
), '[]'::jsonb),
    updated_at = NOW()
WHERE key = 'smtp';

-- Safe initial CamCore identity and public URL settings.
UPDATE settings SET value = '"CamCore News & Updates"'::jsonb, updated_at = NOW()
WHERE key = 'app.site_name';

UPDATE settings SET value = '"https://camcore.au/news"'::jsonb, updated_at = NOW()
WHERE key = 'app.root_url';

UPDATE settings SET value = '"CamCore <help@camcore.au>"'::jsonb, updated_at = NOW()
WHERE key = 'app.from_email';

-- Public archive is required for /news. Public self-subscription stays off
-- until CamCore explicitly decides to enable it.
UPDATE settings SET value = 'true'::jsonb, updated_at = NOW()
WHERE key = 'app.enable_public_archive';

UPDATE settings SET value = 'false'::jsonb, updated_at = NOW()
WHERE key = 'app.enable_public_subscription_page';

UPDATE settings SET value = 'false'::jsonb, updated_at = NOW()
WHERE key = 'app.send_optin_confirmation';

UPDATE settings SET value = '[]'::jsonb, updated_at = NOW()
WHERE key = 'app.notify_emails';
