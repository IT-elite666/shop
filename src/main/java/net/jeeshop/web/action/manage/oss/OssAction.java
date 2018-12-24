package net.jeeshop.web.action.manage.oss;import com.alibaba.fastjson.JSON;import net.jeeshop.core.KeyValueHelper;import net.jeeshop.core.ManageContainer;import net.jeeshop.core.exception.NotThisMethod;import net.jeeshop.core.oscache.ManageCache;import net.jeeshop.services.manage.oss.OssService;import net.jeeshop.services.manage.oss.bean.AliyunOSS;import net.jeeshop.services.manage.oss.bean.Oss;import net.jeeshop.web.action.BaseController;import org.apache.commons.lang.StringUtils;import org.slf4j.Logger;import org.slf4j.LoggerFactory;import org.springframework.beans.factory.annotation.Autowired;import org.springframework.stereotype.Controller;import org.springframework.ui.ModelMap;import org.springframework.web.bind.annotation.ModelAttribute;import org.springframework.web.bind.annotation.RequestMapping;import org.springframework.web.servlet.mvc.support.RedirectAttributes;import javax.servlet.http.HttpServletRequest;import java.util.HashMap;import java.util.Map;/** * 存储方式 * @author huangf * @author dylan * */@Controller@RequestMapping("/manage/oss/")public class OssAction extends BaseController<Oss> {	private static final long serialVersionUID = 1L;	private static final Logger logger = LoggerFactory.getLogger(OssAction.class);	@Autowired	private OssService ossService;	@Autowired	private ManageCache manageCache;	private static final String page_toList = "/manage/oss/ossList";	private static final String page_toEdit = "/manage/oss/ossEdit";	private static final String page_toAdd = "/manage/oss/ossEdit";	private OssAction() {		super.page_toList = page_toList;		super.page_toAdd = page_toAdd;		super.page_toEdit = page_toEdit;	}	public ManageCache getManageCache() {		return manageCache;	}	public void setManageCache(ManageCache manageCache) {		this.manageCache = manageCache;	}	public OssService getService() {		return ossService;	}	@Override	public String insert(HttpServletRequest request, Oss e, RedirectAttributes flushAttrs) throws Exception {		comm(e);		getService().insert(e);		e.clear();		manageCache.loadOSS();		return selectList(request, e);	}	@Override	public String update(HttpServletRequest request, Oss e, RedirectAttributes flushAttrs) throws Exception {		comm(e);		getService().update(e);		e.clear();		manageCache.loadOSS();		return selectList(request, e);	}	@Override	public String deletes(HttpServletRequest request, String[] ids, @ModelAttribute("e") Oss e, RedirectAttributes flushAttrs) throws Exception {		throw new NotThisMethod(ManageContainer.not_this_method);	}		//根据code获取名称	private void comm(Oss e) {		logger.error("comm..code="+e.getCode());				if(StringUtils.isBlank(e.getCode())){			throw new NullPointerException("code不能为空！");		}//		if(StringUtils.isBlank(e.getOssJsonInfo())){//			throw new NullPointerException("配置信息不能为空！");//		}				String name = KeyValueHelper.get("oss_code_"+e.getCode());		if(StringUtils.isBlank(name)){			throw new NullPointerException("未配置"+e.getCode()+"的存储方式的键值对！");		}				e.setName(name);				/*		 * 对配置信息项进行检查		 */		if(e.getCode().equals(Oss.code_aliyun)){//阿里云			logger.error("e.getAliyunOSS().toString()="+e.getAliyunOSS().toString());						try {				e.setOssJsonInfo(JSON.toJSONString(e.getAliyunOSS()));			} catch (Exception ex) {				ex.printStackTrace();			}//			AliyunOSS oss = JSON.parseObject(e.getOssJsonInfo(), AliyunOSS.class);//			if(oss==null){//				throw new RuntimeException("阿里云OSS的配置信息错误！");//			}		}	}		@Override	public String toEdit(Oss e, ModelMap model) throws Exception {		e = getService().selectOne(e);//		if(e==null || StringUtils.isBlank(e.getId())){//			throw new NullPointerException("");//		}		if(StringUtils.isNotBlank(e.getOssJsonInfo())){			try {				e.setAliyunOSS(JSON.parseObject(e.getOssJsonInfo(), AliyunOSS.class));			} catch (Exception ex) {				ex.printStackTrace();			}		}		model.addAttribute("e", e);		return page_toEdit;	}		public static void main(String[] args) {		Map<String,String> map = new HashMap<String, String>();		map.put("ACCESS_ID", "xx");		map.put("ACCESS_KEY", "xx");		map.put("OSS_ENDPOINT", "http://oss.aliyuncs.com/");		map.put("bucketName", "xx");		System.out.println(JSON.toJSONString(map));	}}