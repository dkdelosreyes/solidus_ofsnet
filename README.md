# README

Here's a localhost setup guide to run this app on your machine:

* Dependencies
    - PostgreSQL 11.10 or higher
    - Ruby 2.5.1 or higher
    - Rails 6.0.0
    - Yarn 1.10.1 or higher
    - Mailhog (optional for email testing in local)

* Configuration
    1. Update node modules. On terminal, run this command
        `yarn install --check-files`

* Database creation
    1. This will create the database defined in database.yml
        `rails db:create`

* Initialization
    1. Run migration to prepare the database
        `rails db:migrate`
    2. Populate database
        `rails db:seed`
    3. Create an `.env` file in the root directory then copy the contents from `env-sample.txt`.
    4. Create an `.env.development.local` file in the root directory then copy the contents from `env-development-local-sample.txt`.

* Running on localhost
    1. Go to your terminal.
    2. Depending on how you setup your postgresSQL, make sure you run it on terminal.
        `postgres -D /usr/local/var/postgres`
    3. Update gems if there are new ones.
        `bundle install`
    4. On a separate terminal tab, At the root of your project folder, run the rails server
        `rails server`
    5. Open http://localhost:3000/ on your browser.
    6. To access the admin dashboard:
        Link: http://localhost:3000/admin
        Username: admin@example.com
        Password: test123

* Deployment instructions
    - Initial setup:
        1. Place the code on a private repository such as GIT.
        2. Install AWS EB CLI. Guide: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html
        3. Initialize EB on this project
            `eb init`

            ```
              Select a default region: 6 (ap-south-1)
              Select an application to use: 2 (solidus_ofsnet_prod)
            ```

    - Deploying changes:
        1. Make sure that your changes are final. Then run `eb deploy`.
        2. Wait for it to finish deploying. Monitor it on your terminal or in AWS under Elastic Beanstalk > Environments > solidus-ofsnet-prod.
        3. Once done, changes will reflect in onefabshop.net.

Check the ff. sites for more Info:
https://aws.amazon.com/elasticbeanstalk/
https://guides.rubyonrails.org/getting_started.html
https://guides.solidus.io/developers/
https://www.youtube.com/watch?v=0mxGzk1Lfwg
