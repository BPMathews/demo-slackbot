package env

import "os"

var (
	SlackBotSettings slackBotSettings
)

func init() {
	printVersion()

	slackToken, tokenExists := os.LookupEnv("SLACK_TOKEN")

	if !tokenExists {
		panic("No slack token available")
	} else {
		SlackBotSettings.Token = slackToken
	}

	slackBotName, nameExists := os.LookupEnv("SLACK_BOT_NAME")

	if nameExists {
		SlackBotSettings.Name = slackBotName
	} else {
		SlackBotSettings.Name = "Robot"
	}

	slackBotImage, imageExists := os.LookupEnv("SLACK_BOT_IMAGE")

	if imageExists {
		SlackBotSettings.ImageURL = slackBotImage
	} else {
		SlackBotSettings.ImageURL = "https://bpmathews.com/images/roboDashIcon.png"
	}

}
