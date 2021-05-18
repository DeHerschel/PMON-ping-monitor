@extends('layouts.app')

<?php
$hosts_json = file_get_contents("/tmp/pmon/hosts.json");
$hosts = json_decode($hosts_json);
$hosts_arr = json_decode($hosts_json, true);
$n_hosts = count($hosts_arr);
?>
@section('content')
<div class="container d-flex flex-column h-100">
<div id="container">
     <?php
        for ($i=1; $i <= $n_hosts; $i++) {
            $hostname = "HOST".$i;
            if ($i == 1) {
                echo '
                <div class="row">
                <div class="col-md-3" id="content"></article>
                <div class="wrapper">';
                $hostfilename = strtolower($hostname);
                $hostfilename = "/tmp/pmon/".$hostfilename.".json";
                $host_json = file_get_contents($hostfilename);
                $host = json_decode($host_json);
                echo $hosts->$hostname->HOST;
                echo "<br>";
                echo $host->STATE;
                echo "<br>";
                echo $host->TIME;
                echo '</div>
                </div>';
            }
            elseif ($i%4 == 0) {
                echo '<div class="col-md-3" id="content"></article>
                <div class="wrapper">';
                $hostfilename = strtolower($hostname);
                $hostfilename = "/tmp/pmon/".$hostfilename.".json";
                $host_json = file_get_contents($hostfilename);
                $host = json_decode($host_json);
                echo $hosts->$hostname->HOST;
                echo "<br>";
                echo $host->STATE;
                echo "<br>";
                echo $host->TIME;
                echo '</div>
                </div>
                </div>';
            }
            elseif ($i%4 == 1) {
                echo '
                <div class="row">
                <div class="col-md-3" id="content"></article>
                <div class="wrapper">';
                $hostfilename = strtolower($hostname);
                $hostfilename = "/tmp/pmon/".$hostfilename.".json";
                $host_json = file_get_contents($hostfilename);
                $host = json_decode($host_json);
                echo $hosts->$hostname->HOST;
                echo "<br>";
                echo $host->STATE;
                echo "<br>";
                echo $host->TIME;
                echo '</div>
                </div>';
            }
            else {
                echo '
                <div class="col-md-3" id="content"></article>
                <div class="wrapper">';
                $hostfilename = strtolower($hostname);
                $hostfilename = "/tmp/pmon/".$hostfilename.".json";
                $host_json = file_get_contents($hostfilename);
                $host = json_decode($host_json);
                echo $hosts->$hostname->HOST;
                echo "<br>";
                echo $host->STATE;
                echo "<br>";
                echo $host->TIME;
                echo '</div>
                </div>';
            }
        }
        ?>
</div>
</div>

@endsection
