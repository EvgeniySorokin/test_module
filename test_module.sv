module test_module
#(
parameter DATA_W = 8
)
(
input logic clk_in,
input logic reset_in,
input logic [(DATA_W - 1) : 0] data_in,

output logic [(DATA_W - 1) : 0] out_0, 
output logic out_valid_0, 
output logic [(DATA_W - 1) : 0] out_1, 
output logic out_valid_1, 
output logic [(DATA_W - 1) : 0] out_2, 
output logic out_valid_2, 
output logic [(DATA_W - 1) : 0] out_3, 
output logic out_valid_3 
);

logic [(DATA_W - 1) : 0] data_in_reg;
logic [(DATA_W - 1) : 0] out_0_reg; 
logic out_valid_0_reg;

logic [(DATA_W - 1) : 0] out_1_reg; 
logic out_valid_1_reg;

logic [(DATA_W - 1) : 0] out_2_reg; 
logic out_valid_2_reg;

logic [(DATA_W - 1) : 0] out_3_reg; 
logic out_valid_3_reg;


enum bit[3:0] {ST_IDLE,ST_0,ST_1,ST_1_CHNG,ST_2,ST_2_CHNG,ST_3,ST_3_CHNG} state,next_state;
/*
Конечный автомат для обработки очередного входного значения data_in;
На следующий такт после перехода сброса в 0 переходит с состояние S_0;
S_0 - прием первого значения data_in после сброса;
ST_1_CHNG - прием нового значения data_in, если активен только out_valid_0_reg
или запись в out_0_reg значения data_in, а в out_0_reg значения out_1_reg, если 
(out_0_reg!=data_in && out_1_reg==data_in);
логика следующих состояний схода с вышеописанной 
*/
always_ff @(posedge clk_in )
begin
	if(reset_in)
	begin
		state <= ST_IDLE;
		
	end else
		state <= next_state;
end


always_comb
begin
        case(state )
            ST_IDLE:
                next_state = ST_0;
            ST_0:
                if(data_in_reg!=data_in)
                    next_state = ST_1_CHNG;
                else
                    next_state = ST_0;
            ST_1:
                if(out_0_reg!=data_in && out_1_reg!=data_in)
                    next_state = ST_2_CHNG;
                else if(out_0_reg!=data_in)
                    next_state = ST_1_CHNG;
                else
                    next_state = ST_1;
            ST_1_CHNG:
                if(data_in_reg != data_in && out_0_reg!=data_in && (out_1_reg!=data_in || (!out_valid_1_reg)))
                    next_state = ST_2_CHNG;
                else if(data_in_reg != data_in)
                    next_state = ST_1_CHNG;
                else	
                    next_state = ST_1;
            ST_2:
               if(out_0_reg!=data_in  && out_1_reg!=data_in && out_2_reg!=data_in)
                    next_state = ST_3_CHNG;
                else if(out_0_reg!=data_in)
                    next_state = ST_2_CHNG;
                else
                    next_state = ST_2;
            ST_2_CHNG:
                if(data_in_reg != data_in && out_0_reg!=data_in && out_1_reg!=data_in && ((out_2_reg!=data_in)|| (!out_valid_2_reg)))
                    next_state = ST_3_CHNG;
                else if(data_in_reg != data_in)
                    next_state = ST_2_CHNG;
                else
                    next_state = ST_2;
            ST_3:
                if(out_0_reg!=data_in)
                    next_state = ST_3_CHNG;
                else
                    next_state = ST_3;
            ST_3_CHNG:
                if(data_in_reg!=data_in)
                    next_state = ST_3_CHNG;
                else
                    next_state = ST_3;
            default:
                next_state = ST_IDLE;
        endcase
    
end


/*
Реализация задержки, что бы  было соответствие условию и сортировки для 
избежания одинаковых значения на нескольких выходах
*/
always_ff @(posedge clk_in )
begin
	if(reset_in)
	begin
		out_0_reg <= 0;
		out_1_reg <= 0;
		out_2_reg <= 0;
		out_3_reg <= 0;
		out_valid_0_reg <= 1'b0;
		out_valid_1_reg <= 1'b0;
		out_valid_2_reg <= 1'b0;
		out_valid_3_reg <= 1'b0;
		data_in_reg<=1'b0;
	end
	else
	begin
		if(state == ST_0)
		begin
			out_0_reg <= data_in_reg;
			out_valid_0_reg <= 1'b1;
		end
		if(state == ST_1_CHNG)
		begin
			out_0_reg <= data_in_reg;
			out_1_reg <= out_0_reg;
			out_valid_1_reg <= 1'b1;
		end
			
		if(state == ST_2_CHNG)
		begin
			out_0_reg <= data_in_reg;
			out_1_reg <= out_0_reg;
			if(data_in_reg!=out_1_reg || !out_valid_2_reg)out_2_reg <= out_1_reg;
			out_valid_2_reg <= 1'b1;
		end
		
		if(state == ST_3_CHNG)
		begin
			out_0_reg <= data_in_reg;
			out_1_reg <= out_0_reg;
			if(data_in_reg!=out_1_reg )out_2_reg <= out_1_reg;
			if((data_in_reg!=out_2_reg && data_in_reg!=out_1_reg )|| !out_valid_3_reg)out_3_reg <= out_2_reg;
			out_valid_3_reg <= 1'b1;
		end
		
        data_in_reg<=data_in;
	end	
	
	
end


assign  out_0 = out_0_reg;
assign  out_1 = out_1_reg;
assign  out_2 = out_2_reg;
assign  out_3 = out_3_reg;
assign	out_valid_0 = out_valid_0_reg;
assign	out_valid_1 = out_valid_1_reg;
assign	out_valid_2 = out_valid_2_reg;
assign	out_valid_3 = out_valid_3_reg;
endmodule