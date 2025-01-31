n_elm = 64;
freq = 5000000;
c = 1540;
lambda = c / freq;
elem_width = lambda / 2;
elem_pitch = lambda / 2;

D = ( n_elm - 1 ) * elem_pitch + elem_width
D_to_mid = D / 2

p_ref = [0,0,0]
p_mid = [D_to_mid, 0, 0]
p_focal_1 = [D / 2, 0, 0.01]
p_focal_10 = [D / 2, 0, 0.1]

D_mid_focal_1 = sqrt((p_mid(1)-p_focal_1(1))^2 + (p_mid(2)-p_focal_1(2))^2 + (p_mid(1)-p_focal_1(1))^2);
D_mid_focal_10 = sqrt((p_mid(1)-p_focal_10(1))^2 + (p_mid(2)-p_focal_10(2))^2 + (p_mid(1)-p_focal_10(1))^2);
D_ref_focal_1 = sqrt((p_ref(1)-p_focal_1(1))^2 + (p_ref(2)-p_focal_1(2))^2 + (p_ref(1)-p_focal_1(1))^2);
D_ref_focal_10 = sqrt((p_ref(1)-p_focal_10(1))^2 + (p_ref(2)-p_focal_10(2))^2 + (p_ref(1)-p_focal_10(1))^2);
delay_1 = 1/c * (D_ref_focal_1 - D_mid_focal_1)
delay_10 = 1/c * (D_ref_focal_10 - D_mid_focal_10)

disp([num2str(delay_1*10^6), ' milliseconds'])
