package logger

import (
	"io"
	"os"

	log "github.com/sirupsen/logrus"
	"gopkg.in/natefinch/lumberjack.v2"
)

var Log *log.Logger

func InitLogger() {
	Log = log.New()

	_, err := os.Stat("logs")
	if os.IsNotExist(err) {
		os.Mkdir("logs", 0755)
	}

	logFile := &lumberjack.Logger{
		Filename:   "logs/q-story.log",
		MaxSize:    20,
		MaxBackups: 5,
		MaxAge:     30,
		Compress:   true,
	}

	Log.SetOutput(io.MultiWriter(os.Stdout, logFile))

	Log.SetFormatter(&log.TextFormatter{FullTimestamp: true})
	Log.SetLevel(log.InfoLevel)
}
