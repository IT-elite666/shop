<%@page import="net.jeeshop.web.util.FastDFSClient"%>
<%@page import="net.jeeshop.core.front.SystemManager"%>
<%@page import="com.alibaba.fastjson.JSONObject"%>
<%@page import="org.slf4j.Logger"%>
<%@page import="org.slf4j.LoggerFactory"%>
<%@page import="net.jeeshop.core.util.ImageUtils"%>
<%@page import="net.jeeshop.core.oss.OSSObjectSample"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="net.jeeshop.core.ManageContainer"%>
<%@ page import="java.util.*,java.io.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.disk.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<%@ page
	import="net.jeeshop.services.manage.systemSetting.bean.SystemSetting"%>
<%-- <%@ page import="org.json.simple.*" %> --%>
<%
	/**
	 * KindEditor JSP
	 * 
	 * 本JSP程序是演示程序，建议不要直接在实际项目中使用。
	 * 如果您确定直接使用本程序，使用之前请仔细确认相关安全设置。
	 * 
	 */
	Logger logger = LoggerFactory.getLogger(OSSObjectSample.class);
	logger.debug("1.开始上传文件...");
	SystemSetting systemSetting = SystemManager.getInstance().getSystemSetting();
	//文件保存目录路径--项目的部署的真实路径
	String savePath = pageContext.getServletContext().getRealPath("/") + "attached/";
	//String savePath = "D:\\workspace\\myshop\\web\\attached\\";//pageContext.getServletContext().getRealPath("/") + "attached/";
	System.out.println(pageContext.getServletContext().getRealPath("/") + "attached/");
	//文件保存目录URL
	//String saveUrl  = systemSetting.getImageRootPath()+"/attached/";//request.getContextPath() + "/attached/";
	String saveUrl = systemSetting.getImageRootPath() + "/attached/";
	String imageRootPath = systemSetting.getImageRootPath() ;

	//定义允许上传的文件扩展名
	HashMap<String, String> extMap = new HashMap<String, String>();
	extMap.put("image", "gif,jpg,jpeg,png,bmp");
	extMap.put("flash", "swf,flv,mp3,wav,wma,wmv,mid,avi,mpg,asf,rm,rmvb");
	extMap.put("media", "swf,flv,mp3,wav,wma,wmv,mid,avi,mpg,asf,rm,rmvb");
	extMap.put("file", "doc,docx,xls,xlsx,ppt,htm,html,txt,zip,rar,gz,bz2");

	//最大文件大小 10M
	long maxSize = 1024 * 1204 * 10;
	session.setAttribute("ajax_upload", 1);
	response.setContentType("text/html; charset=UTF-8");
	//检查是否上传了文件
	if (!ServletFileUpload.isMultipartContent(request)) {
		out.println(getError("请选择文件。"));
		return;
	}
	//检查目录
	File uploadDir = new File(savePath);
	if (!uploadDir.isDirectory()) {
		out.println(getError("上传目录不存在。"));
		return;
	}
	//检查目录写权限
	if (!uploadDir.canWrite()) {
		out.println(getError("上传目录没有写权限。"));
		return;
	}

	String dirName = request.getParameter("dir");
	if (dirName == null) {
		dirName = "image";
	}

	if (!extMap.containsKey(dirName)) {
		out.println(getError("目录名不正确。"));
		return;
	}

	//创建文件夹
	savePath += dirName + "/";
	saveUrl += dirName + "/";
	File saveDirFile = new File(savePath);
	if (!saveDirFile.exists()) {
		saveDirFile.mkdirs();
	}

	SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
	String ymd = sdf.format(new Date());
	savePath += ymd + "/";
	saveUrl += ymd + "/";
	File dirFile = new File(savePath);
	if (!dirFile.exists()) {
		dirFile.mkdirs();
	}

	DiskFileItemFactory factory = new DiskFileItemFactory();
	File repository = (File) application.getAttribute("javax.servlet.context.tempdir");
	factory.setRepository(repository);
	ServletFileUpload upload = new ServletFileUpload(factory);
	upload.setHeaderEncoding("UTF-8");
	List items = upload.parseRequest(request);
	//session.setAttribute("ajax_upload", null);
	Iterator itr = items.iterator();
	while (itr.hasNext()) {
		FileItem item = (FileItem) itr.next();
		String fileName = item.getName();
		long fileSize = item.getSize();
		if (!item.isFormField()) {
			//检查文件大小
			if (item.getSize() > maxSize) {
				out.println(getError("上传文件大小超过限制。"));
				return;
			}
			//检查扩展名
			String fileExt = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
			if (!Arrays.<String>asList(extMap.get(dirName).split(",")).contains(fileExt)) {
				out.println(getError("上传文件扩展名是不允许的扩展名。\n只允许" + extMap.get(dirName) + "格式。"));
				return;
			}

			SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
			String newFileName1 = null;//小图
			String newFileName2 = null;//中图
			String newFileName3 = null;//大图 ，也是原图
			synchronized (OSSObjectSample.lock) {
				String newFileName0 = String.valueOf(System.currentTimeMillis());
				logger.error("newFileName0=" + newFileName0);
				newFileName1 = newFileName0 + "_1";
				newFileName2 = newFileName0 + "_2";
				newFileName3 = newFileName0 + "_3." + fileExt;
			}
			logger.debug("newFileName1=" + newFileName1 + ",newFileName2=" + newFileName2 + ",newFileName3="
					+ newFileName3);
			//		String newFileName = df.format(new Date()) + "_" + new Random().nextInt(1000) + "." + fileExt;
			String rootPath = "attached/" + dirName + "/" + df.format(new Date()) + "/";//云存储目录前缀
			//String newFileName1_filePath = rootPath + newFileName1;
			//String newFileName2_filePath = rootPath + newFileName2;
			//String newFileName3_filePath = rootPath + newFileName3;

			File uploadedFile3 = new File(savePath, newFileName3);
			try {
				item.write(uploadedFile3);
				//item.write(uploadedFile2);
				//item.write(uploadedFile3);
				//等比列缩放原图，并且存储
				//ImageUtils.ratioZoom(uploadedFile3, savePath, newFileName1, fileExt, Integer.valueOf(SystemManager.getInstance().get("product_image_1_w")), Integer.valueOf(SystemManager.getInstance().get("product_image_1_h")));
				//ImageUtils.ratioZoom(uploadedFile3, savePath, newFileName2, fileExt, Integer.valueOf(SystemManager.getInstance().get("product_image_2_w")), Integer.valueOf(SystemManager.getInstance().get("product_image_2_h")));

				File uploadedFile1 = new File(savePath, newFileName1 + "." + fileExt);
				File uploadedFile2 = new File(savePath, newFileName2 + "." + fileExt);

				ImageUtils.ratioZoom2(uploadedFile3, uploadedFile1,
						Double.valueOf(SystemManager.getInstance().getProperty("product_image_1_w")));
				ImageUtils.ratioZoom2(uploadedFile3, uploadedFile2,
						Double.valueOf(SystemManager.getInstance().getProperty("product_image_2_w")));
				boolean aliyunOSS = "aliyun"
						.equalsIgnoreCase(SystemManager.getInstance().getProperty("file.upload.oss"));
			/* 	if (aliyunOSS) {
					OSSObjectSample.save(rootPath + newFileName1 + "." + fileExt, uploadedFile1);
					OSSObjectSample.save(rootPath + newFileName2 + "." + fileExt, uploadedFile2);
					OSSObjectSample.save(rootPath + newFileName3, uploadedFile3);
				} */

				//fastdfs方式存储

				// 2、创建一个FastDFS的客户端
				FastDFSClient fastDFSClient = new FastDFSClient("classpath:fastDFS.conf");

				InputStream fis = new FileInputStream(uploadedFile3);

				byte[] arr = new byte[fis.available()];

				fis.read(arr);

				// 3、执行上传处理
				String path1 = fastDFSClient.uploadFile(arr, fileExt);
				// 4、拼接返回的url和ip地址，拼装成完整的url
				newFileName3 = path1;

			} catch (Exception e) {
				e.printStackTrace();
				logger.error("上传文件异常：" + e.getMessage());
				out.println(getError("上传文件失败。"));
				return;
			}
			
			JSONObject obj = new JSONObject();
			obj.put("error", 0);
			obj.put("url", imageRootPath + newFileName3);
			out.println(obj.toJSONString());
		}
	}
%>
<%!private String getError(String message) {
		JSONObject obj = new JSONObject();
		obj.put("error", 1);
		obj.put("message", message);
		return obj.toJSONString();
	}%>