## Bank Finite State Machine

```
clk        : __--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__
req_valid  : _______------------------------___________________________________________
req_ready  : ___________________________----___________________________________________
state      : IDLE      | ACTIVATING    |BA |RDI| BA        |  PRECHARGING  | IDLE
act_gnt    : _______----_______________________________________________________________
rd_gnt     : ___________________________----___________________________________________
pre_gnt    : _______________________________________________----_______________________
counter    :   0       | 3 | 2 | 1 |   0   | 0 |     0         | 3 | 2 | 1 | 0 |
```


| Current state | output                                                                  | Next state                    |
| ------------- | ----------------------------------------------------------------------- | ----------------------------- |
| S_IDLE        | act_gnt = req_valid & tRC_met;<br /> counter_n = act_gnt ? tRCD-2:'d0;  | S_ACTIVATING on act_gnt       |
| S_ACTIVATING  | counter_n = counter - 'd1;                                              | S_BANK_ACTIVE on counter=='d0 |
| S_BANK_ACTIVE | wr_gnt = req_valid & (req_ra==open_ra) & (req_wr==1'b1); <br /> rd_gnt = req_valid & (req_ra==open_ra) & (req_wr==1'b0); <br /> pre_gnt = ( (req_valid & (req_ra!=open_ra)) \| (row_open_cnt=='d0) ) & tRAS_met & tRTP_met & tWTR_met; <br />counter_n = (wr_gnt \| rd_gnt) ? BL/2-'d2 : pre_gnt) ? tRP -'d2 : 'd0;                                           | S_WRITING on wr_gnt <br /> S_READING on rd_gnt <br /> S_PRECHARGING on pre_gnt |
| S_READING     | counter_n = counter - 'd1                                               | S_BANK_ACTIVE on counter=='d0 |
| S_WRITING     | counter_n = counter - 'd1                                               | S_BANK_ACTIVE on counter=='d0 |
| S_PRECHARGING | counter_n = counter - 'd1                                               | S_IDLE on counter=='d0        |
