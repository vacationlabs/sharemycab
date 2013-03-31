create table trip (
  id serial primary key,
  name varchar not null,
  email varchar not null,
  airport varchar not null,
  arrival_datetime timestamp without time zone not null,
  flight_no varchar not null,
  time_tolerance integer not null,
  km_tolerance integer not null,
  address varchar not null,
  lat numeric(10,7) not null,
  long numeric(10,7) not null,
  phonenumber varchar not null,
  status varchar(50) not null
);