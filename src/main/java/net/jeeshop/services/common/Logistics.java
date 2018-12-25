package net.jeeshop.services.common;

import java.io.Serializable;

/**
 * 物流信息
 *
 * @author 陈涛
 *	2018年12月23日
 */
public class Logistics implements Serializable{

	private static final long serialVersionUID = 1L;
	//接口Appkey
	private String key = "4582f35b6da6ccc123f889d5b98586ca";
	//快递公司名称
	private String com;
	//快递订单编号
	private String no;
	public String getKey() {
		return key;
	}
	public void setKey(String key) {
		this.key = key;
	}
	public String getCom() {
		return com;
	}
	public void setCom(String com) {
		this.com = com;
	}
	public String getNo() {
		return no;
	}
	public void setNo(String no) {
		this.no = no;
	}
	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	@Override
	public String toString() {
		return "Logistics [key=" + key + ", com=" + com + ", no=" + no + "]";
	}
	
	
	
}
