package mypkg;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class FakeRepo extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response)
    throws IOException, ServletException
    {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.println("<html>");
        out.println("<head>");
        out.println("<title>Fake JFrog Platform | Welcome</title>");
        out.println("</head>");
        out.println("<body>");
        out.println("<h1>Welcome to fake JFrog Platform (Java Servlet)</h1>");
        out.println("</body>");
        out.println("</html>");
    }
}
