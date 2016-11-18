# health path has a non-obvious name so we don't receive extraneous requests (health checks are potentially expensive)
LUMUMBA_HEALTH_PATH = 'e77d2101447c9b3e4e1547635'

OkComputer.mount_at = LUMUMBA_HEALTH_PATH
