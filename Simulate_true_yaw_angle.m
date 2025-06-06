% Simulate true yaw angle
true_yaw = 45 * sin(2*pi*0.05*time);  % +/- 45 degrees yaw rotation

% Simulate gyroscope yaw rate (derivative + noise)
gyro_yaw_rate = [0, diff(true_yaw)/dt] + randn(size(time))*1.5;

% Simulate magnetometer readings based on yaw
mag_x = cosd(true_yaw) + randn(size(time))*0.05;  % add some noise
mag_y = -sind(true_yaw) + randn(size(time))*0.05;

% Calculate yaw from magnetometer
yaw_mag = atan2(-mag_y, mag_x) * (180/pi);  % in degrees

% Ensure yaw_mag stays between -180 and 180
yaw_mag = mod(yaw_mag + 180, 360) - 180;

% Complementary filter for yaw
yaw_fused = zeros(size(time));
yaw_fused(1) = yaw_mag(1);

alpha = 0.95;

for i = 2:length(time)
    yaw_gyro = yaw_fused(i-1) + gyro_yaw_rate(i)*dt;
    
    % Keep yaw in -180 to 180
    yaw_gyro = mod(yaw_gyro + 180, 360) - 180;
    
    yaw_fused(i) = alpha * yaw_gyro + (1 - alpha) * yaw_mag(i);
end

% Plot yaw results
figure;
plot(time, true_yaw, 'k-', 'LineWidth', 2); hold on;
plot(time, yaw_mag, 'r--o', 'LineWidth', 1);
plot(time, yaw_fused, 'b-', 'LineWidth', 2);
legend('True Yaw', 'Mag Yaw', 'Fused Yaw');
xlabel('Time (s)');
ylabel('Yaw (deg)');
title('Yaw Angle Estimation');
grid on;
