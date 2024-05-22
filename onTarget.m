function phi0 = onTarget(x0, Theta, T)
    % onTarget calculates the initial displacement angle such that
    % the pendulum hits the vertical line x = x0 after time T.
    % x0: target x position (number)
    % Theta: function handle that returns [theta(t); theta_dot(t); theta_ddot(t)] as a column vector
    % T: terminal time (number)
    % phi0: initial displacement angle (number)

    % Initial angular velocity
    omega0 = 0;

    % Define the function to calculate the final x position
    function x = final_x(phi0)
        % Initial conditions
        Phi0 = [phi0; omega0];
        pos = pendulum(Phi0, Theta, T);
        x = pos(1);
    end

    % Define the function for Newton's method
    function Fx = F(phi0)
        Fx = final_x(phi0) - x0;
    end

    % Use dnewton to find the initial displacement phi0 that makes the final x position equal to x0
    tol = 1e-6;
    maxit = 100;
    phi0 = dnewton(0, @F, tol, maxit); % Starting guess is 0
end

% Define the function Theta(t)
function theta_vec = Theta(t)
    % Simple linear motion for theta(t)
    theta_t = (pi / 6) * t; % theta(t)
    theta_dot_t = pi / 6; % theta_dot(t)
    theta_ddot_t = 0; % theta_ddot(t)
    theta_vec = [theta_t; theta_dot_t; theta_ddot_t];
end

% Test the onTarget function
%!test
%! x0 = 0.5;
%! T = 2;
%! phi0 = onTarget(x0, @Theta, T)
%! % Verify that the pendulum hits the target x = x0 at time T
%! pos = pendulum([phi0; 0], @Theta, T)
%! assert(pos(1), x0, 1e-4)
