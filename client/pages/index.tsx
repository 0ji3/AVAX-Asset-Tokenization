import type { NextPage } from "next";
import DefaultLayout from "../components/Layout/DefaultLayout";
import HomeContainer from "../components/Container/HomeContainer";

const Home: NextPage = () => {
  return (
    <DefaultLayout home>
      <HomeContainer />
    </DefaultLayout>
  );
};

export default Home;