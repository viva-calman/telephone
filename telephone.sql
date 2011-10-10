create table calls (
	id int NOT NULL auto_increment,
	source varchar(255),
	destination varchar(255),
	start datetime,
	answer datetime,
	end datetime,
	duration int,
	status smallint,
	primary key(id)
) charset=utf8;

create table status (
	id int NOT NULL auto_increment,
	status varchar(255),
	primary key(id)
	)charset=utf8;
	
create table proxylist (
	id int NOT NULL auto_increment,
	proxyname varchar(255),
	proxystring varchar(255),
	cost float,
	unit smallint,
	primary key(id)
) charset=utf8;

create table userlist (
	id int NOT NULL auto_increment,
	number int,
	name varchar(255),
	district int,
	description varchar(255),
	primary key (id),
	foreign key (district) references districtlist(id)
	) charset=utf8;
	
create table districtlist (
	id int NOT NULL auto_increment,
	name varchar(255),
	primary key (id)
	) charset=utf8;
	