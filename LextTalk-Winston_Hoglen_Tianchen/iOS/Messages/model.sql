CREATE TABLE Users (
userId INTEGER,
localUserId INTEGER,
name TEXT,
learningLang TEXT,
learningFlag INTEGER,
speakingLang TEXT,
speakingFlag INTEGER,
url TEXT,
urlUpdateDate REAL,
activityUpdateDate REAL,
lastUpdateDate REAL,
userDeleted BOOLEAN,
lastDate REAL,
unread INTEGER,
totalNumber INTEGER,

CONSTRAINT PK_Users
	PRIMARY KEY (userId, localUserID)
);

CREATE TABLE Messages (
messageId INTEGER,
localUserId INTEGER,
body TEXT,
date REAL,
utc TEXT,
status INTEGER,
fromUser INTEGER,
toUser INTEGER,

CONSTRAINT PK_Messages
	PRIMARY KEY (messageId, localUserId)
	
);

CREATE INDEX IDX_Messages ON Messages (localUserId, fromUser, toUser, date);
CREATE INDEX IDX_Users ON Users (localUserId, unread, lastDate);