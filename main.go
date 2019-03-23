package main

import (
	"bitbucket.org/BPMathews/demo-slackbot/env"
	"bitbucket.org/BPMathews/demo-slackbot/slack"
)

func main() {
	slack.Start(env.SlackBotSettings.Token)
}
