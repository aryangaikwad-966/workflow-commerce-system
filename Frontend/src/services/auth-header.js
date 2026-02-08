export default function authHeader() {
    const user = JSON.parse(localStorage.getItem("user"));
    console.log("DEBUG AUTH: User from storage:", user);

    if (user && user.token) {
        console.log("DEBUG AUTH: Token found, sending header:", 'Bearer ' + user.token);
        return { Authorization: 'Bearer ' + user.token };
    } else {
        console.log("DEBUG AUTH: No token found in user object");
        return {};
    }
}
