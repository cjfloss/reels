class AsyncMessage {

	public string command;
	
	public void* data;
	
	public AsyncMessage(string com, void* dat) {
		this.command = com;
		this.data = dat;
	}

}
