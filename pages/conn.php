<?php
	$connection = new mysqli('localhost', 'root', '', 'vetdb');

	if ($connection->connect_error) {
	    die("Connection failed: " . $connection->connect_error);
	}
	
?>