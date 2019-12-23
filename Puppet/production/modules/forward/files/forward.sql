CREATE TABLE forward (
	rowid INTEGER NOT NULL AUTO_INCREMENT,
	bron VARCHAR(32),
	doel VARCHAR(32),
	methode VARCHAR(32),
	provision VARCHAR(32) DEFAULT 'present',
	archive VARCHAR(32) DEFAULT 'n',
	timestamp INT(11),
	PRIMARY KEY (rowid)
);
