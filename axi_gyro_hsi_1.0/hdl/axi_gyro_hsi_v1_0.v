
`timescale 1 ns / 1 ps


	module axi_gyro_hsi_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

        // Parameters of Axis Master Bus Interface MM00_AXIS
        parameter integer ADDR_WIDTH = 12,
        parameter integer C_AXIS_TDATA_WIDTH = 32,

		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here
        output wire MCK,
        output wire HSICKA0,
        output wire HSICKA1,
        input wire HSIA0,
        input wire HSIA1,
        
		// User ports ends
		// Do not modify the ports beyond this line
		
        // Ports of Axis Master Bus Interface in FIFO
        output  wire  tclock,
        output wire   tresetn,
        //input  wire  m00_axis_aresetn,
        output wire [C_AXIS_TDATA_WIDTH-1:0] tdata,
        //output wire [(C_AXIS_TDATA_WIDTH/8)-1:0] m00_axis_tstrb,
        output wire tvalid,
        input  wire tready,
        output wire tlast,

		// Ports of Axi Slave Bus Interface S00_AXI
		input  wire  s00_axi_aclk,
		input  wire  s00_axi_aresetn,
		input  wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input  wire [2 : 0] s00_axi_awprot,
		input  wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input  wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input  wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input  wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
	
	wire        tclk_int;
	wire [31:0] tdata_int;
    wire  [3:0] tstrb_int;
    wire        tvalid_int;
    wire        tready_int;
    wire        tlast_int;
	
// Instantiation of Axi Bus Interface S00_AXI
	axi_gyro_hsi_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) axi_gyro_hsi_v1_0_S00_AXI_inst (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),
		 .MCK(MCK),
        .HSICKA0(HSICKA0),
        .HSICKA1(HSICKA1),
        .HSIA0(HSIA0),
        .HSIA1(HSIA1),
        .tclock(tclk_int),
        .tdata(tdata_int),
        .tstrb(tstrb_int),
        .tvalid(tvalid_int),
        .tready(tready_int),
        .tlast(tlast_int)
	);

	// Add user logic here
	assign tclock = tclk_int;
	assign tresetn = s00_axi_aresetn;
	assign tdata = tdata_int;
	//assign m00_axis_tstrb = tstrb_int;
	assign tvalid = tvalid_int;
	assign tready = tready_int;
    assign tlast = tlast_int;
	// User logic ends

	endmodule
