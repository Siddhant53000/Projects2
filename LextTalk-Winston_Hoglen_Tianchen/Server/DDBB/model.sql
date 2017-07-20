CREATE TABLE Locales (
master_lan VARCHAR(40),
locale VARCHAR(6), 
CONSTRAINT PK_Locales
	PRIMARY KEY (master_lan)
);

CREATE TABLE Languages (
master_lan VARCHAR(40),
app_lan VARCHAR(40),
lan_name VARCHAR(40),
CONSTRAINT PK_Languages
	PRIMARY KEY (master_lan, app_lan),
CONSTRAINT FK_Languages
	FOREIGN KEY (master_lan)
	REFERENCES Locales(master_lan)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);

CREATE TABLE Flags (
master_lan VARCHAR(40),
id INTEGER,
flag BLOB,
CONSTRAINT PK_Flags
	PRIMARY KEY (master_lan, id),
CONSTRAINT FK_Flags
	FOREIGN KEY (master_lan)
	REFERENCES Locales(master_lan)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);




CREATE TABLE SpeakLocales (
master_lan VARCHAR(40),
id INTEGER,
locale VARCHAR(6),
CONSTRAINT PK_SpeakLocales
	PRIMARY KEY (master_lan, id)
);

CREATE TABLE SpeakLanguages (
master_lan VARCHAR(40),
app_lan VARCHAR(40),
id INTEGER,
speak_name VARCHAR(40),
CONSTRAINT PK_SpeaLanguages
	PRIMARY KEY (master_lan, app_lan, id),
CONSTRAINT FK_SpeakLanguages
	FOREIGN KEY (master_lan)
	REFERENCES SpeakLocales(master_lan)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);