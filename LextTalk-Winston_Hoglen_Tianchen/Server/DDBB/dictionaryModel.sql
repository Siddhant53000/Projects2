CREATE TABLE Dicts (
fromLan VARCHAR(40),
toLan VARCHAR(40),
CONSTRAINT PK_Dicts
	PRIMARY KEY (fromLan, toLan)
);

CREATE TABLE Definitions (
fromLan VARCHAR(40),
toLan VARCHAR(40),
original TEXT,
translated TEXT,
CONSTRAINT PK_Definitions
	PRIMARY KEY (fromLan, toLan, original),
CONSTRAINT FK_Definitions
	FOREIGN KEY (fromLan, toLan)
REFERENCES Dicts(fromLan, toLan)
	ON UPDATE CASCADE
	ON DELETE CASCADE	
);