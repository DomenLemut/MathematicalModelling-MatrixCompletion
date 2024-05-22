function pos = pendulum(Phi0, Theta, T)
    % Phi0: initial conditions [phi0; omega0] as a column vector
    % Theta: function handle that returns [theta(t); theta_dot(t); theta_ddot(t)] as a column vector
    % T: terminal time
    % pos: position [x; y] of the point mass at time T as a column vector

    % Extract initial conditions
    phi0 = Phi0(1);
    omega0 = Phi0(2);

    % Parameters
    g = 1;
    L = 1;
    ell = 1;

    % Initial conditions
    Phi = [phi0; omega0];

    % Define the system of first-order differential equations
    function dPhi = equations(t, Phi)
        phi = Phi(1);
        omega = Phi(2);

        % Get theta, theta_dot, and theta_ddot from the Theta function
        theta_vec = Theta(t);
        theta = theta_vec(1);
        theta_dot = theta_vec(2);
        theta_ddot = theta_vec(3);

        % Define the equations
        dphi_dt = omega;
        domega_dt = (-g * sin(phi) - ell * theta_ddot * cos(theta - phi) + ell * theta_dot^2 * sin(theta - phi)) / L;

        dPhi = [dphi_dt; domega_dt];
    end

    % RK4 parameters
    h = 0.01; % step size
    N = round(T / h); % number of steps
    t = 0; % initial time

    % RK4
    for i = 1:N
        k1 = h * equations(t, Phi);
        k2 = h * equations(t + 0.5*h, Phi + 0.5*k1);
        k3 = h * equations(t + 0.5*h, Phi + 0.5*k2);
        k4 = h * equations(t + h, Phi + k3);

        Phi = Phi + (k1 + 2*k2 + 2*k3 + k4) / 6;
        t = t + h;
    end

    % Get the final values of phi and omega at time T
    phi_T = Phi(1);

    % Get the final value of theta at time T
    theta_T = Theta(T)(1);

    % Calculate the position [x; y] of the point mass at time T
    x = ell * sin(theta_T) + L * sin(phi_T);
    y = -ell * cos(theta_T) - L * cos(phi_T);

    % Return the position as a column vector
    pos = [x; y];
end

% Define the function Theta(t)
function theta_vec = Theta(t)
    % Simple linear motion for theta(t)
    theta_t = (pi / 6) * t; % theta(t)
    theta_dot_t = pi / 6; % theta_dot(t)
    theta_ddot_t = 0; % theta_ddot(t)
    theta_vec = [theta_t; theta_dot_t; theta_ddot_t];
end

% Define tests
%!test
%! Phi0 = [pi/6; 0];
%! T = 2;
%! pos = pendulum(Phi0, @Theta, T);
%! expected_x = 0.68946
%! expected_y = -1.4843
%! assert(pos(1), expected_x, 1e-4)
%! assert(pos(2), expected_y, 1e-4)
