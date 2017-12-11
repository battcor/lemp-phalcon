<?php

$response = new \Phalcon\Http\Response();

$response->setStatusCode(500, "OK");
$response->setContent("HELLO");

$response->send();
