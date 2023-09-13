<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.TimeZone" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="refresh" content="5">
    <title>JFrog Artifactory | Fake Login</title>
    <link rel="stylesheet" href="css/reset.css?v=1.0">
    <link rel="stylesheet" href="css/index.css?v=1.0">
    <script src="js/index.js"></script>

</head>

<body>
    <div class="row">
        <div class="column left">
            <!--JFROG_BANNER-->
        </div>
        <div class="column right">
            <div class="welcome">
                <span class="greet-text">WELCOME TO JFROG PLATFORM</span>
                <span class="greet-text-descr">
                    <p>*an universal DevOps solution</p>
                    <p>providing end-to-end automation and management</p>
                    <p>of binaries and artifacts</p>
                    <p>through the application delivery</p>
                </span>
            </div>
            <div class="right-bottom">
                <span class="java-msg">welcome.jsp
                    <%
                       SimpleDateFormat dtFormat = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");
                       dtFormat.setTimeZone(TimeZone.getTimeZone("Asia/Omsk"));
                    %>
                    [<%= new String(dtFormat.format(new Date()))%> (GMT+06)]
                </span>
            </div>
        </div><!--left-->
    </div><!--row-->

    <script>
        console.log("Welcome to fake JFrog Artifactory")
    </script>
    <script src="js/logic.js"></script>

</body>
</html>
