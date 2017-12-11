<?php
/**
* Resources Class
*/
class Resources {

    protected $verbose = false;
    protected $header = false;
    protected $userAgent = 'X-Client: MM-IH API Tester';
    protected $credentials;
    protected $timeout = 60;

    public function __construct() {}

    public function setCredentials($value)
    {
        $this->credentials = $value;
    }

    public function getCredentials()
    {
        return $this->credentials;
    }

    public function callApi($url, $data, $method = 'POST', $customHeader = array(), $basicAuth = false)
    {
        $curl = curl_init();

        curl_setopt($curl, CURLOPT_VERBOSE, $this->verbose);
        curl_setopt($curl, CURLOPT_HEADER, $this->header);
        curl_setopt($curl, CURLOPT_USERAGENT, $this->userAgent);
        curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, $this->timeout);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, TRUE);

        switch($method)
        {
            case 'POST':
                curl_setopt($curl, CURLOPT_URL, $url);
                curl_setopt($curl, CURLOPT_POST, TRUE);
                curl_setopt($curl, CURLOPT_POSTFIELDS, http_build_query($data, null, '&', PHP_QUERY_RFC3986));
                break;
            case 'GET':
                curl_setopt($curl, CURLOPT_URL, $url . '?' . http_build_query($data));
                break;
            case 'PUT':
                curl_setopt($curl, CURLOPT_URL, $url);
                curl_setopt($curl, CURLOPT_POSTFIELDS, http_build_query($data, null, '&', PHP_QUERY_RFC3986));
                curl_setopt($curl, CURLOPT_CUSTOMREQUEST, 'PUT');
                $customHeader[] = 'Content-Type: www-form-urlencoded';
                break;
            case 'DELETE':
                curl_setopt($curl, CURLOPT_URL, $url);
                curl_setopt($curl, CURLOPT_POSTFIELDS, http_build_query($data, null, '&', PHP_QUERY_RFC3986));
                curl_setopt($curl, CURLOPT_CUSTOMREQUEST, 'DELETE');
                $customHeader[] = 'Content-Type: www-form-urlencoded';
                break;
        }

        if(!empty($customHeader)){
            curl_setopt($curl, CURLOPT_HTTPHEADER, $customHeader);
        }

        // BLIND
        curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, 0);
        curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, FALSE);

        // AUTHENTICATION
        if($basicAuth){
            curl_setopt($curl, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
            curl_setopt($curl, CURLOPT_USERPWD, $this->getCredentials());
        }

        $result = curl_exec($curl);
        $info = curl_getinfo($curl);

        $response['http_code'] = $info['http_code'];
        $response['body'] = ($info['http_code'] == 504) ? trim(preg_replace('/\s\s+/', ' ', strip_tags($result))) : $result;

        curl_close($curl);
        return $response;
    }


}

$res = new Resources();

$response = $res->callApi('http://127.0.0.1/test.php', [], 'GET');

print_r($response);
