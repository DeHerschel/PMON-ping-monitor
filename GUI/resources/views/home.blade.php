@extends('layouts.app')
<script src="js/jquery.js"></script>

@section('content')
<div class="container d-flex flex-column h-100" id="container">
 <script>
    $(document).ready(function() {
      //$(".dial").knob();
        var color = 'green'
        $('.dial').knob({
            'min':0,
            'max':100,
            'width':"100%",
            'height':"100%",
            'displayInput':true,
            'fgColor':color,
            'readOnly':true,
            'draw' : function () { $(this.i).val(this.cv.toFixed(1) + 'ms').css('font-size', '15pt').css('color', 'black'); }
        });
        function setColor(){
        	m = document.getElementsByClass('input').value
            m = m.slice(0, -2);
            if (m <= 25) {
				color='green';
			}
			else if (m > 30 && m <= 70) {
				color='yellow';
			}
			else if (m > 70) {
				color = 'red';
			}
            $('.dial').trigger('configure', {'fgColor':color});
        }
		setColor()
    });
  </script>
   <?php
        $hosts_json = file_get_contents("/tmp/pmon/hosts.json");
        $hosts = json_decode($hosts_json);
        $hosts_arr = json_decode($hosts_json, true);
        $n_hosts = count($hosts_arr);
        for ($i=1; $i <= $n_hosts; $i++) {
            $hostname = "HOST".$i;
            if ($i == 1) {
                echo '
                <div class="row">
                <div class="col-md-3 host-state" id="content" style="background-color:#FFFFFF; margin: 1%;">';

                echo '</div>';
            }
            elseif ($i%4 == 0) {
                echo '<div class="col-md-3 host-state" id="content" style="background-color:#FFFFFF; margin: 1%;">';
                echo "<h2 style='font-size:15pt;margin-left:15%; margin-top:10%; margin-bottom:5%'>".$hosts->$hostname->HOST."<h2>";
                echo '<div class="wrapper">';
                $hostfilename = strtolower($hostname);
                $hostfilename = "/tmp/pmon/".$hostfilename.".json";
                $host_json = file_get_contents($hostfilename);
                $host = json_decode($host_json);

                echo '<input type="text" class="dial" value="'.number_format(floatval($host->TIME), 1).'" id="input" >';
                echo '</div>';
                echo "<h3 style='font-size:15pt;margin-left:15%; margin-top:2%; margin-bottom:2%'>".$hosts->$hostname->IP."<h3>";
                echo "<h4 style='font-size:15pt;margin-left:15%; margin-bottom:2%'>".$host->STATE."<h4>";
                echo '</div>
                </div>';
            }
            elseif ($i%4 == 1) {
                echo '
                <div class="row">
                <div class="col-md-3 host-state" id="content" style="background-color:#FFFFFF; margin: 1%;">';
                echo "<h2 style='font-size:15pt;margin-left:15%; margin-top:10%; margin-bottom:5%'>".$hosts->$hostname->HOST."<h2>";
                echo '<div class="wrapper">';
                $hostfilename = strtolower($hostname);
                $hostfilename = "/tmp/pmon/".$hostfilename.".json";
                $host_json = file_get_contents($hostfilename);
                $host = json_decode($host_json);
                 echo '<input type="hidden"  value="'. $hosts->$hostname->HOST.'" id="host" >';
                echo '<input type="hidden" value="'.$host->STATE.'" id="state" >';
                echo '<input type="text" class="dial" value="'.number_format(floatval($host->TIME), 1).'" id="input" >';
                echo '</div>';
                echo "<h3 style='font-size:15pt;margin-left:15%; margin-top:2%; margin-bottom:2%'>".$hosts->$hostname->IP."<h3>";
                echo "<h4 style='font-size:15pt;margin-left:15%;  margin-bottom:2%'>".$host->STATE."<h4>";
                echo '</div>';
            }
            else {
                echo '
                <div class="col-md-3 host-state" id="content" style="background-color:#FFFFFF; margin: 1%;">';
                echo "<h2 style='font-size:15pt;margin-left:15%; margin-top:10%; margin-bottom:5%'>".$hosts->$hostname->HOST."<h2>";
                echo '<div class="wrapper">';
                $hostfilename = strtolower($hostname);
                $hostfilename = "/tmp/pmon/".$hostfilename.".json";
                $host_json = file_get_contents($hostfilename);
                $host = json_decode($host_json);
                echo '<input type="hidden"  value="'. $hosts->$hostname->HOST.'" id="host" >';
                echo '<input type="hidden" value="'.$host->STATE.'" id="state" >';
                echo '<input type="text" class="dial" value="'.number_format(floatval($host->TIME), 1).'" id="input" >';
                echo '</div>';
                echo "<h3 style='font-size:15pt;margin-left:15%; margin-top:2%; margin-bottom:2%'>".$hosts->$hostname->IP."<h3>";
                echo "<h4 style='font-size:15pt;margin-left:15%; margin-bottom:2%'>".$host->STATE."<h4>";
                echo '</div>';
            }
        }
        ?>
@endsection
