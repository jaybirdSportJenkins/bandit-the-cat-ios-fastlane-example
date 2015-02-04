# fastlane example with Bandit The Cat
==========================

## My Additions
- Gemfile
  - Manage all my lane dependencies - dotenv, Shenzen, AWS, etc.
- fastlane/.env
  - Allows me to store varialbes in a `.env` file
  - None of my credential or API keys are sitting in the lane logic
  - Makes reusing my lanes in other projects easier (only need a new `.env`)
  - I can include `.env` in my `.gitignore` file so no one else has my credentials
