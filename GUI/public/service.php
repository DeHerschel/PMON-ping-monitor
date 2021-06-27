<?php
if ($_POST) {
    shell_exec("service pmon ".$_POST{'state'});
    sleep(3);
    header('Location: /home');
    die();
}
?>
