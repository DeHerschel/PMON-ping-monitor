
<?php
        $hostname = $_POST['hostname'];
        header('Content-type: application/json; charset=utf-8');
        $hosts_json = file_get_contents("/tmp/pmon/hosts.json");
        $hosts = json_decode($hosts_json);
        $hosts_arr = json_decode($hosts_json, true);
        $n_hosts = count($hosts_arr);
        $hostfilename = strtolower($hostname);
        $hostfilename = "/tmp/pmon/".$hostfilename.".json";
        $host_json = file_get_contents($hostfilename);
        echo $host_json;
?>
