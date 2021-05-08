<script>
    import * as _ from 'lodash';
    import { onMount } from 'svelte';
    
    
    let langInfo = [];

    onMount(async () => {
        fetch("/api/wordInfo/" + "Czech/pes").then((r) => {return r.json()}).then((d) => {langInfo = d })
    })

</script>

<div>
    {#each langInfo as datum, i}
        <div>
            <h3>{datum.title.replace("[ edit ]", "").replace("[edit]", "")}</h3>
            {#each datum.content as content, j}
                {#if content.tag == "p"}
                <p id={`${i}:${j}`}>{content.innerContent.replace("\n", "")}</p>
                {:else if content.tag == "ul" || content.tag == "ol"}
                <ul id={`${i}:${j}`}>
                    {#each content.innerContent as innerContent}
                        <li>{innerContent.replace("\n", "")}</li>
                    {/each}
                </ul>
                {:else if content.tag="table"}
                <table id={`${i}:${j}`}>
                    <tbody>
                        {#each content.innerContent as innerContent, k}
                            <tr>
                                {#each innerContent as inner, l}
                                    <td id={`${k}:${l}`}>{inner.replace("\n", "")}</td>
                                {/each}
                            </tr>
                        {/each}
                    </tbody>
                </table>
                {/if}
            {/each}
        </div>
    {/each}
</div>

<style></style>