# Travel Canny

This repository is for a now defunct project I worked on called Travel Canny. This is the Rails app that ran the Wireless Network using [Twilio's Programmable Wireless](https://www.twilio.com/wireless). The business prospects of it weren't great but the setting up a custom, programmable wireless network was pretty interesting and I thought worth sharing, so I am open sourcing the app.

## What it is

The main idea for the project was to create a simple, easy-to-use, works everywhere SIM card. In order to do that, you need a SIM card and a configurable wireless network. Luckily, [Twilio's Programmable Wireless product](https://www.twilio.com/wireless) was perfect for this. Although, it is mostly meant for programming IoT devices, with a few tweaks and customizations you can use it to set up your own wireless network.

This app consists of:
* Admin Dashboard: to manage things like users, shipping, payments, etc.
* Webhooks: interact with and manage the Twilio Programmable Wireless network
* Frontend/API: skeleton SPA setup for users to interact with their accounts

## How it works

This app allows you to create your own wireless network using Twilio's Programmable Wireless product.

The main part of the app is an Admin Dashboard where you can create and edit users, manage and track shipments of SIM cards (to your users), manage and track SIM cards and data usage, and jump to external services like Stripe and Twilio.

The actual management of the wireless network is handled by the app code and Twilio. The details for how to set this up are below. As far as the user experience goes, the app works as follows:
* A user account is set up by an admin
* An admin user packages and ships a SIM card to a user. When they update the shipment in the dashboard to shipped and add a tracking link, the user receives an email notifying them that their SIM card is on its way and gives them a link to track it.
* The admin sets the data plan for the SIM card
* Upon receiving the SIM card, the user puts it in their phone and connects to the network.
* Once a user gets below a set amount of data on their plan, they will receive an automatic text message that tells them. This text message includes a link to a webpage where they can add a credit card for more data, or they can simply respond with "Add" if they already have a credit card on file and their data plan will be updated automatically and their SIM card re-enabled if de-activated.

## How to use

### TLDR;

<a href="https://heroku.com/deploy" target="_blank">
  <img src="https://www.herokucdn.com/deploy/button.svg" alt="Deploy">
</a>

### Configure
The app requires a Twilio account, Stripe account, SendGrid account, and Mailchimp account. Once you have those accounts set up, you'll need to grab their api keys and configure the following project environment variables:

* `TWILIO_ACCOUNT_SID`
* `TWILIO_AUTH_TOKEN`
* `STRIPE_API_KEY`
* `STRIPE_PUBLIC_KEY`
* `SENDGRID_USERNAME`
* `SENDGRID_API_KEY`
* `MAILCHIMP_API_KEY`
* `MAILCHIMP_MARKETING_LIST_ID`

Mailchimp isn't actually necessary to run the app, it just adds all new users to a marketing email list, but I figured to leave it in to see how that was done. If you don't need this part either leave the environment variables empty and let those methods fail silently or remove them completely. They can be found in the callback methods on the `User` model.

#### Twilio Programmable Wireless

The key part of the app is using it to run and set up the Twilio Programmable Wireless product. In order to actually manage SIM cards, data plans, payment for services, and network tests, you'll have to do a little bit of set up on [Twilio](https://twilio.com/console).

To do this, log into your Twilio console and navigate to the [Programmable Wireless](https://www.twilio.com/console/wireless/overview) section. Once there, the first thing you'll have to do is actually order SIM cards from Twilio. You can do that under the `Order` tab. Assuming you now have some SIM cards from Twilio to use, you can now begin to set them up to work with the app.

The first thing you'll need to do is set up some data plans. You'll have to decide how you want to run your network for your specific use case but the way Travel Canny was set up was that I created three different data plans on Twilio:
* A main data plan for all activated users
* A test data plan for testers (not actual users)
* A data plan to switch users to when they reached their limits to shut off their data connection but still allow text and calls to go through

The way the app works is that all active users with data allowances get put on the main data plan. Because Travel Canny was meant to be as simple to use as possible and work anywhere, that meant the main data plan had all services enabled (Data, Voice, Messaging), allowed both National and International Roaming, and set all data limits to 100,000 MB/month.

How to actually set up a data plan on Twilio is outside the scope of this Readme but if you would like to learn more about them and how to do it, you can do so [here](https://www.twilio.com/docs/wireless/understanding-rate-plans).

Setting the main data plan up in this way allowed for the flexibility to control limitations programmatically instead of having to jump into the Twilio dashboard everytime a change needed to be made. That would be infeasible. So instead, I set it up so that everything was turned on. The app is what controls a user's actual data plan and usage. Set the `TWILIO_SIM_RATE_PLAN_SID` environment variable to the SID of the data plan you created on Twilio.

The next plan type you'll want to set up is the disabled data plan. This is a plan that allows text messages and calls to go through but does not have data. That way, when a user hits their data limit in the app, instead of having to manually switch them or disable their SIM card, which would prevent texts or calls, you just update the SIM card to use the disabled plan that you set up programmatically. Set the `TWILIO_DISABLED_DATA_SIM_RATE_PLAN_SID` environment variable to the SID of this data plan on Twilio.

I also set up a test data plan that was limited in data because it was strictly meant for testing purposes. You'll also find that there is some network testing code in the `app/controllers/webhooks/twilio/network_test_controller.rb` file. They use two environment variables called `NETWORK_TEST_SURVEY_CODE` and `NETWORK_TEST_SURVEY_INPUT` in order to verify testing but you can ignore these if you'd like. If using a test plan, make sure to set the `TWILIO_TEST_SIM_RATE_PLAN_SID` environment variable to the SID of it on Twilio.

Finally, in order to send out warning text messages to users that their data is running low, you have to buy a Twilio phone number and set the `TWILIO_NOTIFICATION_PHONE_NUMBER` environment variable to it. Notification messages will be sent from that.

Here are the Twilio related environment variables again:
* `TWILIO_SIM_RATE_PLAN_SID`
* `TWILIO_DISABLED_DATA_SIM_RATE_PLAN_SID`
* `TWILIO_TEST_SIM_RATE_PLAN_SID`
* `NETWORK_TEST_SURVEY_CODE`
* `NETWORK_TEST_SURVEY_INPUT`
* `TWILIO_NOTIFICATION_PHONE_NUMBER`

Once you've got that all set up you're good to start adding users! Note that when adding users, upon creating a new user, the app will pull all the available SIM cards from your Twilio account and pick one to give to the new user automatically. It will fail if you don't have any available SIM cards to use.

The other environment variables that the app uses are:

* `DOMAIN_NAME`
* `SECRET_KEY_BASE`
* `CLIENT_API_KEY`: for frontend app
* `ANALYTICS_API_KEY`: for Segment analytics

## License
Released under the MIT License. See [LICENSE](LICENSE) or http://opensource.org/licenses/MIT for more information.