@extends('layouts.app')
<script src="js/jquery.js"></script>
 <div id="sidebar-wrapper" class="navbar navbar-expand-md expand-md column d-flex flex-columnfixed-left fixed-top gradient-omg">
    <div class="container">
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarsidecontent" aria-controls="navbarsidecontent" aria-expanded="false" aria-label="{{ __('Toggle navigation') }}">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="navbar-nav collapse navbar-collapse" id="navbarsidecontent">
            <ul class="sidebar-nav nav-pills nav-stacked">
                <li class="nav-item">
                    <a href="/" class="nav-link "><span class=" fa-stack fa-lg pull-left"><i class="fa fa-home fa-stack-1x "></i></span>HOME</a>
                </li>
                <li class="nav-item panel pane-default">
                    <a data-toggle="collapse" href="#collapse1" class="nav-link" ><span class="fa-stack fa-lg pull-left"><i class="fa fa-server fa-stack-1x "></i></span>HOSTS</a>
                    <div id="collapse1" class="panel-collapse collapse">
                        <ul class="nav-pills nav-stacked list-group" aria-labelledby="navbarDropdown" style="list-style-type:none;">
                           <?php
                                if (file_exists("/tmp/pmon/hosts.json")) {
                                    $hosts_json = file_get_contents("/tmp/pmon/hosts.json");
                                    $hosts = json_decode($hosts_json);
                                    $hosts_arr = json_decode($hosts_json, true);
                                    $n_hosts = count($hosts_arr);
                                    for ($i=1; $i <= $n_hosts; $i++) {
                                        $hostname = "HOST".$i;
                                        $hostfilename = strtolower($hostname);
                                        $hostfilename = "/tmp/pmon/".$hostfilename.".json";
                                        $host_json = file_get_contents($hostfilename);
                                        $host = json_decode($host_json);
                                        ?>
                                        <li class="nav-pills nav-item"><a href="/host?host=<?php echo $hostname; ?>" class="nav-link"><span class="fa-stack fa-lg pull-left"><i class="fa fa-flag fa-stack-1x "></i></span> <?php
                                        if ($hosts->$hostname->DOMAIN){
                                            echo $hosts->$hostname->DOMAIN;
                                        }
                                        else {
                                            echo $hosts->$hostname->IP;
                                        }?></a></li>
                                        <?php
                                    }
                                }
                            ?>
                        </ul>
                    </div>
                </li class="nav-item">
                <!-- <li>
                    <a href="#" class="nav-link"><span class="fa-stack fa-lg pull-left"><i class="fa fa-terminal fa-stack-1x "></i></span>CONSOLE</a>
                </li> -->
                <li>
                    <a href="#" class="nav-link"> <span class="fa-stack fa-lg pull-left"><i class="fa fa-cogs fa-stack-1x "></i></span>CONFIGURATION</a>
                </li>

            </ul>
        </div>
    </div>
</div>
            <!-- <img src="images/pmon-logo.png" alt=""> -->
@section('content')

<div class="container container-stats" id="container">
 <script>
    $(document).ready(function() {

       //$(".dial").knob();
         var color = 'green'
         $('.dial').knob({
             'min':0,
             'max':100,
             'step': 0.1,
             'width':"100%",
             'height':"100%",
             'displayInput':true,
             'fgColor':color,
             'readOnly':true,
             'draw' : function () { $(this.i).val(this.cv.toFixed(1) + 'ms').css('font-size', '1.2em').css('color', 'black'); }
         });

     });
  </script>
   <?php
        if (file_exists("/tmp/pmon/hosts.json")) {
        $service_status="running";
        $hosts_json = file_get_contents("/tmp/pmon/hosts.json");
        $hosts = json_decode($hosts_json);
        $hosts_arr = json_decode($hosts_json, true);
        $n_hosts = count($hosts_arr);
        for ($i=1; $i <= $n_hosts; $i++) {
            $hostname = "HOST".$i;
            if ($i == 1) {
                ?>
                <div class="row">
                <div class="col-md-2 align-center" >
                <div class="host-state" id="<?php echo $hostname ?>" style="">

                <div class="wrapper">
                <?php
                $hostfilename = strtolower($hostname);
                $hostfilename = "/tmp/pmon/".$hostfilename.".json";
                $host_json = file_get_contents($hostfilename);
                $host = json_decode($host_json);
                ?>
                <input type="text" class="dial <?php echo $hostname ?>" value="<?php echo $host->TIME ?>" id="<?php echo $hostname ?>" >
                </div>
                <h4><?php echo $host->STATE ?> <h4>
                </div>
                <h3><?php if ($hosts->$hostname->DOMAIN){
                            echo $hosts->$hostname->DOMAIN;
                        }
                        else {
                            echo $hosts->$hostname->IP;
                        } ?><h3>
                </div>
                 <script>
                    <?php echo "host".$i ?> = "<?php echo $hostname ?>"
                    <?php echo "dataHost".$i ?> = { 'hostname': '<?php echo $hostname ?>'}
                    function <?php echo "setColorHost".$i?>(){
                        <?php echo "knobHost".$i ?> = $('.<?php echo $hostname ?>').val()
                        <?php echo "knobHost".$i ?> = <?php echo "knobHost".$i ?>.slice(0, -2);
                        if (<?php echo "knobHost".$i ?> <= 25) {
                            <?php echo 'colorHost'.$i ?> ='green';
                        }
                        else if (<?php echo "knobHost".$i ?> > 25 && <?php echo "knobHost".$i ?> <= 70) {
                            <?php echo 'colorHost'.$i ?> = 'yellow';
                        }
                        else if (<?php echo "knobHost".$i ?> > 70) {
                            <?php echo 'colorHost'.$i ?> = 'red';
                        }
                        $('.<?php echo "host".$i ?>').trigger('configure', {'fgColor':<?php echo 'colorHost'.$i ?>});
                    }
                    setInterval(() => {
                        $.ajax({
                            url: "stats.php",
                            type: "POST",
                            data:  <?php echo "dataHost".$i ?>
                        }).done(function(answer) {
                                console.log(answer)
                                time = answer.TIME
                                time = parseFloat(time).toFixed(1)
                                $('.<?php echo $hostname ?>').val(time);
                                $('.<?php echo $hostname ?>').trigger('change');
                             <?php echo "setColorHost".$i?>();
                            });
                    }, 1000);

                </script>
                <?php
            }
            elseif ($i%4 == 0) {
                ?>
                <div class="col-md-2 align-center" >
                <div class="host-state" id="<?php echo $hostname ?>" style="">

                <div class="wrapper">
                <?php
                $hostfilename = strtolower($hostname);
                $hostfilename = "/tmp/pmon/".$hostfilename.".json";
                $host_json = file_get_contents($hostfilename);
                $host = json_decode($host_json);
                ?>
                <input type="text" class="dial <?php echo $hostname ?>" value="<?php echo $host->TIME ?>" id="<?php echo $hostname ?>" >
                </div>
                <h4><?php echo $host->STATE ?> <h4>
                </div>
                <h3><?php if ($hosts->$hostname->DOMAIN){
                            echo $hosts->$hostname->DOMAIN;
                        }
                        else {
                            echo $hosts->$hostname->IP;
                        }?><h3>


                </div>
                </div>
                 <script>
                    <?php echo "host".$i ?> = "<?php echo $hostname ?>"
                    <?php echo "dataHost".$i ?> = { 'hostname': '<?php echo $hostname ?>'}
                    function <?php echo "setColorHost".$i?>(){
                        <?php echo "knobHost".$i ?> = $('.<?php echo $hostname ?>').val()
                        <?php echo "knobHost".$i ?> = <?php echo "knobHost".$i ?>.slice(0, -2);
                        if (<?php echo "knobHost".$i ?> <= 25) {
                            <?php echo 'colorHost'.$i ?> ='green';
                        }
                        else if (<?php echo "knobHost".$i ?> > 25 && <?php echo "knobHost".$i ?> <= 70) {
                            <?php echo 'colorHost'.$i ?> = 'yellow';
                        }
                        else if (<?php echo "knobHost".$i ?> > 70) {
                            <?php echo 'colorHost'.$i ?> = 'red';
                        }
                        $('.<?php echo "host".$i ?>').trigger('configure', {'fgColor':<?php echo 'colorHost'.$i ?>});
                    }
                    setInterval(() => {
                        $.ajax({
                            url: "stats.php",
                            type: "POST",
                            data:  <?php echo "dataHost".$i ?>
                        }).done(function(answer) {
                                console.log(answer)
                                time = answer.TIME
                                time = parseFloat(time).toFixed(1)
                                $('.<?php echo $hostname ?>').val(time);
                                $('.<?php echo $hostname ?>').trigger('change');
                             <?php echo "setColorHost".$i?>();
                            });
                    }, 1000);

                </script>
                <?php
            }
            elseif ($i%4 == 1) {
                 ?>
                <div class="row">
                <div class="col-md-2 align-center" >
                <div class="host-state" id="<?php echo $hostname ?>" style="">

                <div class="wrapper">
                <?php
                $hostfilename = strtolower($hostname);
                $hostfilename = "/tmp/pmon/".$hostfilename.".json";
                $host_json = file_get_contents($hostfilename);
                $host = json_decode($host_json);
                ?>
                <input type="text" class="dial <?php echo $hostname ?>" value="<?php echo $host->TIME ?>" id="<?php echo $hostname ?>" >
                </div>
                <h4><?php echo $host->STATE ?> <h4>
                </div>
                <h3><?php if ($hosts->$hostname->DOMAIN){
                            echo $hosts->$hostname->DOMAIN;
                        }
                        else {
                            echo $hosts->$hostname->IP;
                        } ?><h3>


                </div>
                 <script>
                    <?php echo "host".$i ?> = "<?php echo $hostname ?>"
                    <?php echo "dataHost".$i ?> = { 'hostname': '<?php echo $hostname ?>'}
                    function <?php echo "setColorHost".$i?>(){
                        <?php echo "knobHost".$i ?> = $('.<?php echo $hostname ?>').val()
                        <?php echo "knobHost".$i ?> = <?php echo "knobHost".$i ?>.slice(0, -2);
                        if (<?php echo "knobHost".$i ?> <= 25) {
                            <?php echo 'colorHost'.$i ?> ='green';
                        }
                        else if (<?php echo "knobHost".$i ?> > 25 && <?php echo "knobHost".$i ?> <= 70) {
                            <?php echo 'colorHost'.$i ?> = 'yellow';
                        }
                        else if (<?php echo "knobHost".$i ?> > 70) {
                            <?php echo 'colorHost'.$i ?> = 'red';
                        }
                        $('.<?php echo "host".$i ?>').trigger('configure', {'fgColor':<?php echo 'colorHost'.$i ?>});
                    }
                    setInterval(() => {
                        $.ajax({
                            url: "stats.php",
                            type: "POST",
                            data:  <?php echo "dataHost".$i ?>
                        }).done(function(answer) {
                                console.log(answer)
                                time = answer.TIME
                                time = parseFloat(time).toFixed(1)
                                $('.<?php echo $hostname ?>').val(time);
                                $('.<?php echo $hostname ?>').trigger('change');
                             <?php echo "setColorHost".$i?>();
                            });
                    }, 1000);

                </script>
                <?php
            }
            else {
               ?>
                <div class="col-md-2 align-center" >
                <div class="host-state" id="<?php echo $hostname ?>" style="">
                <div class="wrapper">
                <?php
                $hostfilename = strtolower($hostname);
                $hostfilename = "/tmp/pmon/".$hostfilename.".json";
                $host_json = file_get_contents($hostfilename);
                $host = json_decode($host_json);
                ?>
                <input type="text" class="dial <?php echo $hostname ?>" value="<?php echo $host->TIME ?>" id="<?php echo $hostname ?>" >
                </div>
                <h4><?php echo $host->STATE ?> <h4>
                </div>
                <h3><?php if ($hosts->$hostname->DOMAIN){
                            echo $hosts->$hostname->DOMAIN;
                        }
                        else {
                            echo $hosts->$hostname->IP;
                        }
                ?><h3>

                </div>
                 <script>
                    <?php echo "host".$i ?> = "<?php echo $hostname ?>"
                    <?php echo "dataHost".$i ?> = { 'hostname': '<?php echo $hostname ?>'}
                    function <?php echo "setColorHost".$i?>(){
                        <?php echo "knobHost".$i ?> = $('.<?php echo $hostname ?>').val()
                        <?php echo "knobHost".$i ?> = <?php echo "knobHost".$i ?>.slice(0, -2);
                        if (<?php echo "knobHost".$i ?> <= 25) {
                            <?php echo 'colorHost'.$i ?> ='green';
                        }
                        else if (<?php echo "knobHost".$i ?> > 25 && <?php echo "knobHost".$i ?> <= 70) {
                            <?php echo 'colorHost'.$i ?> = 'yellow';
                        }
                        else if (<?php echo "knobHost".$i ?> > 70) {
                            <?php echo 'colorHost'.$i ?> = 'red';
                        }
                        $('.<?php echo "host".$i ?>').trigger('configure', {'fgColor':<?php echo 'colorHost'.$i ?>});
                    }
                    setInterval(() => {
                        $.ajax({
                            url: "stats.php",
                            type: "POST",
                            data:  <?php echo "dataHost".$i ?>
                        }).done(function(answer) {
                                console.log(answer)
                                time = answer.TIME
                                time = parseFloat(time).toFixed(1)
                                $('.<?php echo $hostname ?>').val(time);
                                $('.<?php echo $hostname ?>').trigger('change');
                             <?php echo "setColorHost".$i?>();
                            });
                    }, 1000);

                </script>
                <?php
            }
        }
        ?>
</div>
<?php } else {
    $service_status="stopped";
?>
    <h1> PMON IS STOPPED </h1>
<?php
} ?>
<div class="control fixed-bottom">
    <div class="statusdiv">
        <?php
        $status = system("service pmon status", $return);
        echo $return;
        ?>
    </div>
        <div class="servicediv">
            <form action="service.php" method="post">
                <?php
                if ($service_status == 'running') {

                    ?>
                    <input type="hidden" value="stop" name="state">
                    <input type="submit" value="STOP" id="servicebutton">
                <?php
                } else {
                ?>
                    <input type="hidden" value="start" name="state">
                    <input type="submit" value="SATRT" id="servicebutton">
                <?php
                }
                ?>
            </form>
            <br>
            <br>
            <b> <p> PMON is </p><p id="running"><?php echo $service_status ?></p></b>
        </div>
        <script>
            state_service = document.getElementById('running').innerText;
            if (state_service == "stopped") {
                $('#running').css('color', 'red')
                $('#servicebutton').css('background-color', 'rgb(78, 143, 204)')
            }
            if (state_service == "running") {
                $('#servicebutton').css('-webkit-box-shadow', 'inset 1px 1px 1px 1px rgba(100, 100, 100, 0.43)')
                $('#servicebutton').css('-moz-box-shadow', 'inset 1px 1px 1px 1px rgba(100, 100, 100, 0.43)')
                $('#servicebutton').css('box-shadow', 'inset 1px 1px 1px 1px rgba(100, 100, 100, 0.43)')
                $('#servicebutton').css('background-color', 'rgb(113, 179, 240)')
            }
        </script>
    </div>
    @endsection

